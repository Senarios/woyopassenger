import 'package:cheetah_redux/models/direction_details.dart';
import 'package:cheetah_redux/models/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

User firebaseUser;

Users userCurrentInfo;

int driverRequestTimeOut = 80;

// String statusRide = "";
// String rideStatus = "Driver is Coming";

String state = "";
String driverID = "";
String driverName = "";
String carRideType = "";
String carDetailsDriver = "";

String driverphone = "";

double starCounter=0.0;
String title="";

DirectionDetails tripDirectionDetails;
GoogleMapController newGoogleMapController;

String serverToken = "key=AAAA99U5Azs:APA91bG-LMJWz4_nlGcVaUY1SVntxEEvBmBNuAuKzySzwYygo4YhUjO7qx5U-k4Pmvlar_ly1CimPF5kGpKB9bj1dyRtbmME8Y_bTL4Ja14OZ73X-BIez4KdB7cK4mkJwOshjjBw8DPF";

