import Debug "mo:base/Debug";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";

actor KargoDronTakip {
  // Dron konumu bilgileri için veri yapısı
  type DroneLocation = {
    latitude : Float;
    longitude : Float;
    altitude : Float;
    timestamp : Time.Time;
  };

  // Kargo bilgileri
  type CargoInfo = {
    id : Text;
    description : Text;
    status : Text;
  };

  // Dron izleme kayıtları
  let droneLocations = HashMap.HashMap<Text, DroneLocation>(10, Text.equal, Text.hash);
  
  // Kargo bilgileri kayıtları
  let cargoInfos = HashMap.HashMap<Text, CargoInfo>(10, Text.equal, Text.hash);

  // Yeni bir dron konumu kaydet
  public func updateDroneLocation(
    droneId : Text, 
    lat : Float, 
    lon : Float, 
    alt : Float
  ) : async () {
    let location : DroneLocation = {
      latitude = lat;
      longitude = lon;
      altitude = alt;
      timestamp = Time.now()
    };
    
    droneLocations.put(droneId, location);
    Debug.print("Drone " # droneId # " location updated");
  };

  // Dron konumunu sorgula
  public query func getDroneLocation(droneId : Text) : async ?DroneLocation {
    droneLocations.get(droneId)
  };

  // Kargo bilgisi ekle
  public func addCargo(
    cargoId : Text, 
    description : Text, 
    status : Text
  ) : async () {
    let cargoInfo : CargoInfo = {
      id = cargoId;
      description = description;
      status = status
    };
    
    cargoInfos.put(cargoId, cargoInfo);
    Debug.print("Cargo " # cargoId # " added");
  };

  // Kargo durumunu güncelle
  public func updateCargoStatus(
    cargoId : Text, 
    newStatus : Text
  ) : async () {
    switch (cargoInfos.get(cargoId)) {
      case (null) { 
        Debug.print("Cargo not found"); 
      };
      case (?cargo) {
        let updatedCargo : CargoInfo = {
          id = cargo.id;
          description = cargo.description;
          status = newStatus
        };
        cargoInfos.put(cargoId, updatedCargo);
        Debug.print("Cargo " # cargoId # " status updated to " # newStatus);
      };
    };
  };

  // Kargo bilgilerini sorgula
  public query func getCargoInfo(cargoId : Text) : async ?CargoInfo {
    cargoInfos.get(cargoId)
  };

  // Tüm aktif kargo drone'larının listesini al
  public query func getActiveDrones() : async [(Text, DroneLocation)] {
    let activeDrones = Buffer.Buffer<(Text, DroneLocation)>(0);
    
    for ((droneId, location) in droneLocations.entries()) {
      activeDrones.add((droneId, location));
    };
    
    activeDrones.toArray()
  };
  