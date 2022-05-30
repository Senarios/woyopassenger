import 'package:firebase_database/firebase_database.dart';

class RideRequestRepository {
  static DatabaseReference setRideInfo(Map rideInfoMap) {
    var rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();
    rideRequestRef.set(rideInfoMap);
    return rideRequestRef;
  }
}
