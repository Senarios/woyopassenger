

import 'package:firebase_database/firebase_database.dart';

class Driver
{
  String name;
  String phone;
  String email;
  String id;
  String car_details;
  String suggestedAmount;

  Driver({this.name, this.phone, this.id, this.car_details,});

  Driver.fromSnapshot(dynamic dataSnapshot)
  {
    id = dataSnapshot["driver_id"];
    phone = dataSnapshot["driver_phone"];
    name = dataSnapshot["driver_name"];
    if(dataSnapshot["car_details"]!=null) {
      car_details = dataSnapshot["car_details"];
    }
    var amount = dataSnapshot["amount_suggestion"];
    suggestedAmount = amount["from_driver"];
  }
}
