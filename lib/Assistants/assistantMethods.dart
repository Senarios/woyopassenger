import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/models/direction_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
// import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cheetah_redux/models/history.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../main.dart';

User currentfirebaseUser;

class AssistantMethods {
  /* static Future<DirectionDetails> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async
  {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    // var res = await RequestAssistant.getRequest(directionUrl);
    var res = await RequestAssistant.get('maps.googleapis.com', '/maps/api/directions/json',
        {
          'origin' : '${initialPosition.latitude},${initialPosition.longitude}',
          'destination' : '${finalPosition.latitude},${finalPosition.longitude}',
          'key' : mapKey
        });

    if(res == "failed")
    {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }*/

  /* static int calculateFares(DirectionDetails directionDetails)
  {
    //in terms USD
    double timeTraveledFare = (directionDetails.durationValue / 60) * 0.20;
    double distancTraveledFare = (directionDetails.distanceValue / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distancTraveledFare;

    //Local Currency
    //1$ = 160 RS
    //double totalLocalAmount = totalFareAmount * 160;
    if(rideType == "uber-x")
    {
      double result = (totalFareAmount.truncate()) * 2.0;
      return result.truncate();
    }
    else if(rideType == "uber-go")
    {
      return totalFareAmount.truncate();
    }
    else if(rideType == "bike")
    {
      double result = (totalFareAmount.truncate()) / 2.0;
      return result.truncate();
    }
    else
    {
      return totalFareAmount.truncate();
    }
  }*/

/*  static void disableHomeTabLiveLocationUpdates()
  {
    // todo
    // homeTabPageStreamSubscription.pause();
    // Geofire.removeLocation(currentfirebaseUser.uid);

    FirebaseFirestore.instance
        .collection('availableDrivers')
        .doc(currentfirebaseUser.uid)
        .delete();
  }
*/
  /* static void enableHomeTabLiveLocationUpdates()
  {
    // todo
    // homeTabPageStreamSubscription.resume();
    // Geofire.setLocation(currentfirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
    GeoFlutterFire geoFlutterFire = GeoFlutterFire();
    GeoFirePoint point = geoFlutterFire.point(latitude: currentPosition.latitude, longitude: currentPosition.longitude);
    FirebaseFirestore.instance
        .collection('availableDrivers')
        .doc(currentfirebaseUser.uid)
        .set({
      'position': point.data
    });
  } */

  static void retrieveHistoryInfo(context) {
    User newFirebaseUSER = FirebaseAuth.instance.currentUser;
    try {
      rideRequestRef
          .orderByChild("rider_id")
          .equalTo(firebaseUser.uid)
          .once()
          .then((DataSnapshot dataSnapshot) {
        if (dataSnapshot != null) {
          if (dataSnapshot.value != null) {
            Map<dynamic, dynamic> keys = dataSnapshot.value;
            int historyTripCount = keys.length;
            Provider.of<AppDataProvider>(context, listen: false)
                .updateHistoryTripCounter(historyTripCount);
            List<String> historyTripKeys = [];

            // print('KEY:VALUE :: $keys $historyTripCount');

            // print("KEY:VALUE ${keys.keys}");

            keys.forEach((key, value) {
              if (value['rider_id'] == newFirebaseUSER.uid) {
                historyTripKeys.add(key);
              }
            });
            Provider.of<AppDataProvider>(context, listen: false)
                .updateHistoryTripKeys(historyTripKeys);
            obtainHistoryTripRequestsData(context);

            // List<History> tripHistoryDataList = [];
            // for (var data in dataSnapshot.value.values) {
            //   //print("status=${data["status"]}=");
            //   // History.fr
            //   // var history = History.fromSnapshot(data);
            //   // print("DATA: ${dataSnapshot.key..toString()}");
            //   var history = History.fromData(data);

            //   tripHistoryDataList.add(history);
            // }
            // Provider.of<AppDataProvider>(context, listen: false)
            //     .addTripHistoryData(tripHistoryDataList);
          }
        } else {
          retrieveHistoryInfo(context);
        }
      });
    } catch (e) {
      print("ERROR: ${e.toString()}");
    }
  }

  static void obtainHistoryTripRequestsData(context) {
    var keys =
        Provider.of<AppDataProvider>(context, listen: false).historyTripKeys;
    Provider.of<AppDataProvider>(context, listen: false)
        .historyTripDataList
        .clear();
    for (String key in keys) {
      rideRequestRef.child(key).once().then((DataSnapshot snapshot) {
        // print("KEYS : $key");
        // print("VALUE : ${snapshot.value.toString()}");

        if (snapshot.value != null) {
          var history = History.fromSnapshot(snapshot);
          Provider.of<AppDataProvider>(context, listen: false)
              .updateHistoryTripData(history);
          // print('HISTORY SUCCESSS');

        }
      });
    }
  }

  // static void obtainTripRequestsHistoryData(context) {
  //   var keys =
  //       Provider.of<AppDataProvider>(context, listen: false).tripHistoryKeys;
  //   Provider.of<AppDataProvider>(context, listen: false)
  //       .tripHistoryDataList
  //       .clear();
  //   for (String key in keys) {
  //     rideRequestRef.child(key).once().then((DataSnapshot snapshot) {
  //       if (snapshot.value != null) {
  //         var history = History.fromSnapshot(snapshot);
  //         Provider.of<AppDataProvider>(context, listen: false)
  //             .updateTripHistoryData(history);
  //       }
  //     });
  //   }
  // }

  static String formatTripDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDate;
  }
}
