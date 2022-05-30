import 'dart:convert';

import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MessagesNotification {
  static sendNotificationToDriverByDatabase(
      String token, context, String ride_request_id) async {
    var destination =
        Provider.of<AppDataProvider>(context, listen: false).dropOffLocation;

    try {
      var message = constructMessagePayload(
          token, destination.placeName, ride_request_id);

      var rideRequestRef =
          FirebaseDatabase.instance.reference().child("ride-message").push();

      rideRequestRef.set(message);
    } catch (e) {
      // print(e);
    }
  }

  static sendNotificationToDriver(String token, context, String rideRequestId,
      double suggestedAmount) async {
    var destination =
        Provider.of<AppDataProvider>(context, listen: false).dropOffLocation;

    try {
      var headers = {
        'Authorization': serverToken,
        'Content-Type': 'application/json'
      };
      var request = http.Request(
          'POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
      var message = constructFCMPayload(
          token, destination.placeName, rideRequestId, suggestedAmount);
      request.body = message;
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // print(await response.stream.bytesToString());
      } else {
        // print(response.reasonPhrase);
      }

      // print('FCM request for device sent!');
    } catch (e) {
      // print(e);
    }
  }

  static Map constructMessagePayload(
      String token, destinationPlaceName, rideRequestId) {
    Map notification = {
      'body': 'Addresse de destination, ${destinationPlaceName}',
      'title': 'Nouvelle demande de lift',
      'ride_request_id': rideRequestId,
      'status': 'done',
      'id': '1',
      "to": token,
    };

    return notification;
    // Map data =
    // {
    //   'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    //   'id': '1',
    //   'status': 'done',
    //   'ride_request_id': rideRequestId,
    // };
    //
    // return jsonEncode({
    //   'data': data,
    //   "priority": "high",
    //   "to": token,
    //   'notification': notification
    // });
  }

  static String constructFCMPayload(
      String token, destinationPlaceName, rideRequestId, double amount) {
    Map notification = {
      'body': 'Addresse de destination, ${destinationPlaceName}',
      'title': 'Nouvelle demande de lift'
    };

    Map data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_request_id': rideRequestId,
      'suggested_amount': amount
    };

    return jsonEncode({
      'data': data,
      "priority": "high",
      "to": token,
      'notification': notification
    });
  }
}
