import 'package:firebase_database/firebase_database.dart';
import 'package:nb_utils/nb_utils.dart';

class History {
  String fares;
  String pickup;
  String status;
  String riderId;
  String dropOff;
  String rideId;
  String rideType;
  String createdAt;
  // String driverName;
  String paymentMethod;

  History({
    this.fares,
    this.status,
    this.pickup,
    this.dropOff,
    this.riderId,
    this.rideType,
    this.rideId,
    this.createdAt,
    // this.driverName,
    this.paymentMethod,
  });

  History.fromSnapshot(DataSnapshot snapshot) {
    rideId = snapshot.key == null ? '' : snapshot.key;
    riderId =
        snapshot.value["rider_id"] == null ? '' : snapshot.value["rider_id"];
    rideType =
        snapshot.value["ride_type"] == null ? '' : snapshot.value["ride_type"];
    createdAt = snapshot.value["created_at"] == null
        ? ''
        : snapshot.value["created_at"];
    pickup = snapshot.value["pickup_address"] == null
        ? ''
        : snapshot.value["pickup_address"];
    dropOff = snapshot.value["dropoff_address"] == null
        ? ''
        : snapshot.value["dropoff_address"];
    paymentMethod = snapshot.value["payment_method"] == null
        ? ''
        : snapshot.value["payment_method"];
    status = snapshot.value["status"] == null ? "" : snapshot.value["status"];
    // status = lstatus == "CANCELLED_BY_PASSENGER" ? "Cancelled" : lstatus;
    // status = lstatus == "SCHEDULE_TRIP" ? "Schedule Trip" : lstatus;
    // status = lstatus == "ended" ? "Ended" : lstatus;
    // status = lstatus == "" ? "" : lstatus;

    fares = snapshot.value["fares"] == null || snapshot.value["fares"] == '0'
        ? snapshot.value["amount_from_rider"] == null
            ? "0"
            : snapshot.value["amount_from_rider"]
        : snapshot.value["fares"];
    // driverName = snapshot.value[" "];
  }


  History.fromData(Map<dynamic, dynamic> key) {
    // rideId = key;

    riderId = key["rider_id"];

    rideType = key["ride_type"];

    createdAt = key["created_at"];

    pickup = key["pickup_address"];

    dropOff = key["dropoff_address"];

    paymentMethod = key["payment_method"];

    var lstatus = key["status"] == null ? "" : key["status"];

    status = lstatus == "accepted_with_condition" ? "Accepted" : lstatus;

    status = lstatus == "CANCELLED_BY_PASSENGER" ? "Cancelled" : status;

    fares = key["fares"] == null || key["fares"] == '0'
        ? key['amount_from_rider'] == null
            ? "0"
            : key['amount_from_rider']
        : key["fares"];
  }
}
