import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/models/address.dart';
import 'package:cheetah_redux/models/direction_details.dart';
import 'package:cheetah_redux/network/http_handler.dart';
import 'package:cheetah_redux/utils/google_map_key.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cheetah_redux/models/users.dart';

class LocationRepository {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    // String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    // var response = await RequestAssistant.getRequest(url);

    var response = await HttpHandler.get(
        'maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${position.latitude},${position.longitude}',
      'key': googleMapKey
    });

    // print(jsonEncode(response["results"][0]["address_components"]));

    if (response != 'Failed') {
      if (response['results'].length > 0) {
        placeAddress = response["results"][0]["formatted_address"];
        // st1 = response["results"][0]["address_components"][4]["long_name"];
        // st2 = response["results"][0]["address_components"][7]["long_name"];
        // st3 = response["results"][0]["address_components"][6]["long_name"];
        // // st4 = response["results"][0]["address_components"][9]["long_name"];
        // placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

        Address userPickUpAddress = new Address();
        userPickUpAddress.longitude = position.longitude;
        userPickUpAddress.latitude = position.latitude;
        userPickUpAddress.placeName = placeAddress;

        Provider.of<AppDataProvider>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);
      }
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    // String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await HttpHandler.get(
        'maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${initialPosition.latitude},${initialPosition.longitude}',
      'destination': '${finalPosition.latitude},${finalPosition.longitude}',
      'key': googleMapKey
    });

    if (res == "failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    var routes = res["routes"] as List;
    if (routes.isEmpty) {
      return null;
    }
    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapShot) {
      if (dataSnapShot.value != null) {
        userCurrentInfo = Users.fromSnapshot(dataSnapShot);
      }
    });
  }
}
