import 'dart:async';
import 'package:cheetah_redux/Assistants/assistantMethods.dart';
import 'package:cheetah_redux/models/address.dart';
import 'package:cheetah_redux/payment/payment_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/widgets/collect_fare.dart';
import 'package:cheetah_redux/home/widgets/no_driver_available_dialog.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/models/driver.dart';
import 'package:cheetah_redux/models/nearby_available_drivers.dart';
import 'package:cheetah_redux/network/location_repository.dart';
import 'package:cheetah_redux/network/messages_notification.dart';
import 'package:cheetah_redux/network/ride_request_repository.dart';
import 'package:cheetah_redux/services/trip_service.dart';
import 'package:cheetah_redux/utils/custom_button.dart';
import 'package:cheetah_redux/utils/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:stripe_payment/stripe_payment.dart';
import '../main_screen.dart';

class RideDetails extends StatefulWidget {
  const RideDetails({Key key}) : super(key: key);

  @override
  _RideDetailsState createState() => _RideDetailsState();
}

class _RideDetailsState extends State<RideDetails>
    with TickerProviderStateMixin {
  StreamSubscription<Event> rideStreamSubscription;
  bool isRequestingPositionDetails = false;
  bool dialogShowing = false;
  bool checckPaymentMethods = false;
  String paymentMethod = "Cash";

  // String state = "normal";
  // List<NearbyAvailableDrivers> availableDrivers;
  TextEditingController amountSuggestionController = TextEditingController();
  double suggestedAmount;
  bool isOneClickDriverSearch = false;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _userInfo = FirebaseAuth.instance;
  String stripeToken = '';

  PaymentMethod paymentMethods;

  // final List<double> sizes = [120, 160, 200];
  //
  // AnimationController _controller;
  // Animation _animation;

  @override
  void initState() {
    super.initState();
    setState(() {
      String paymentMethod = "Cash";
    });
    getUserInfo();
    PaymentServices.initStripe();

    // _controller = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 3),
    // )
    //   ..repeat()
    //   ..addListener(() {
    //     setState(() {});
    //   });
    // _animation =
    //     CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    // Future.delayed(Duration(seconds: 4), () => Navigator.pushNamed(context, PageRoutes.rideBookedPage));
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  createTokenWithCardForm() {
    StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest())
        .then((paymentMethod) {
      print('paymentMethod ${paymentMethod.toJson()}');
      _firestore.collection('users').doc(_userInfo.currentUser.uid).update({
        "Token": paymentMethod.id,
      });
      setState(() {
        stripeToken = paymentMethod.id;
        paymentMethods = paymentMethod;
      });
    }).catchError(setError);

    Provider.of<AppDataProvider>(context, listen: false)
        .updatestripeToken(stripeToken);
  }

  void setError(dynamic error) {
    displayToastMessage(
      error.toString(),
      context,
    );
  }

  getUserInfo() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(_userInfo.currentUser.uid)
        .get();
    setState(() {
      stripeToken = snapshot['Token'] == null ? '' : snapshot['Token'];
    });
    Provider.of<AppDataProvider>(context, listen: false)
        .updatestripeToken(stripeToken);
    print("stripeToken $stripeToken");
  }

  @override
  Widget build(BuildContext context) {
    // TimeOfDay selectedTime = TimeOfDay.now();
    // _selectTime(BuildContext context) async {
    //   final TimeOfDay timeOfDay = await showTimePicker(
    //     context: context,
    //     initialTime: selectedTime,
    //     initialEntryMode: TimePickerEntryMode.dial,
    //     confirmText: 'CONFIRM',
    //     cancelText: 'NOT NOW',
    //     errorInvalidText: 'Can\'t select this time',
    //   );
    //   if (timeOfDay != null && timeOfDay != selectedTime) {
    //     setState(() {
    //       selectedTime = timeOfDay;
    //       print("Selected Time: $selectedTime");
    //     });
    //   }
    // }
    DateTime _chosenDateTime;

    scheduleTripRequest() {
      rideRequestRef.child("status").set("SCHEDULE_TRIP");
      rideRequestRef.child("time").set("$_chosenDateTime");
      // rideRequestRef.child("time").set("${}");

      setState(() {
        state = "normal";
      });
    }

    bool _timeConversion(DateTime _chosenDateTime) {
      var inputedStartTime = DateTime.parse(_chosenDateTime.toString());
      var mili = inputedStartTime.millisecondsSinceEpoch / 1000;
      var startTime = mili.toInt();

      var inputedENDTime =
          DateTime.parse(DateTime.now().add(Duration(minutes: 5)).toString());
      var miliEND = inputedENDTime.millisecondsSinceEpoch / 1000;
      var endTime = miliEND.toInt();

      var finalTime = endTime - startTime;

      print("COMPARE TO START: $startTime");
      print("COMPARE TO END: $endTime");
      print("COMPARE TO FINAL: ${endTime - startTime}");
      if (finalTime <= 0) {
        return true;
      } else {
        return false;
      }

      // if (_chosenDateTime.compareTo(DateTime.now()) == 1) {
      //   print("Day: ${_chosenDateTime.day}");
      //   if (_chosenDateTime.minute >
      //       DateTime.now().add(Duration(minutes: 5)).minute) {
      //     return true;
      //   } else {
      //     return false;
      //   }
      // } else if (_chosenDateTime.day > DateTime.now().day) {
      //   return true;
      // } else {
      //   return false;
      // }
    }

    var now = DateTime.now();
    var today =
        new DateTime(now.year, now.month, now.day, now.hour, now.minute);
    void _showDatePicker(ctx) {
      // showCupertinoModalPopup is a built-in function of the cupertino library
      showCupertinoModalPopup(
        context: ctx,
        builder: (_) => Container(
          height: 400,
          color: Theme.of(context).primaryColor,
          child: Column(
            children: [
              Container(
                height: 300,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  minimumDate: today,
                  // minuteInterval: 1,
                  onDateTimeChanged: (val) {
                    setState(() {
                      _chosenDateTime = val;
                    });
                  },
                ),
              ),

              // Close the modal
              CupertinoButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  bool newTime = _timeConversion(_chosenDateTime);
                  if (newTime) {
                    print('Time Accepted');
                    scheduleTripRequest();
                    Provider.of<AppDataProvider>(context, listen: false)
                        .updateCurrentRideStatus("NEW");
                    MainScreen.dropOffTextEditingController.text = "";
                    resetApp();
                    Navigator.of(ctx).pop();
                  } else if (!newTime) {
                    print('Time not Accepted');
                    Fluttertoast.showToast(
                      msg: 'Time must be 5 minutes more then current time',
                    );
                  }

                  // Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        ),
      );
    }

//  [More details][2]

    var theme = Theme.of(context);
    // setState(() {
    //   suggestedAmount = TripService.calculateFares(tripDirectionDetails);
    // });
    suggestedAmount = TripService.calculateFares(
        Provider.of<AppDataProvider>(context).tripDirectionDetails);
    if (Provider.of<AppDataProvider>(context).rideTypeStatus == "") {
      setState(() {
        isOneClickDriverSearch = false;
      });
    }
    if (Provider.of<AppDataProvider>(context, listen: false)
            .currentRideStatus ==
        "SEARCH_DRIVER_ONE_CLICK") {
      print("SEARCH_DRIVER_ONE_CLICK_PICKUP");
      if (!isOneClickDriverSearch) {
        setState(() {
          isOneClickDriverSearch = true;
        });
        Provider.of<AppDataProvider>(context, listen: false)
            .updateCurrentRideStatus("SEARCH_DRIVER");
        displayToastMessage("Searching for a driver ...", context);
        MainScreen.dropOffTextEditingController.text = "";

        setState(() {
          state = "requesting";
          carRideType = "jomar-x";
        });

        displayRequestRideContainer();
        searchNearestDriver();
      }
    }

    if (Provider.of<AppDataProvider>(context).rideTypeStatus ==
        "LOCATION_SELECTED_ONE_CLICK_RIDE") {
      Provider.of<AppDataProvider>(context, listen: false)
          .updateCurrentRideStatus("LOCATION_SELECTED");
      setState(() {
        state = "requesting";
        carRideType = "jomar-x";
      });

      displayRequestRideContainer();
      searchNearestDriver();
    }

    return Provider.of<AppDataProvider>(context).currentRideStatus ==
            "LOCATION_SELECTED"
        ? Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: new Duration(milliseconds: 160),
                child: //Provider.of<AppDataProvider>(context).currentRideStatus == "LOCATION_SELECTED" ?
                    PositionedDirectional(
                  bottom: 0,
                  start: 0,
                  end: 0,
                  // top: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: theme.backgroundColor,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: 52,
                        child: Row(
                          children: [
                            Text(
                              Strings.PAYMENT_MODE,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                    fontSize: 13.5,
                                  ),
                            ),
                            Spacer(),
                            Container(
                              width: 1,
                              height: 28,
                              color: theme.hintColor,
                            ),
                            Spacer(),
                            PopupMenuButton(
                              onSelected: (value) {
                                print('Selected');
                              },
                              color: theme.backgroundColor,
                              offset: Offset(0, -144),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Icon(
                                    checckPaymentMethods == false
                                        ? Icons.account_balance_wallet_outlined
                                        : Icons.credit_card_sharp,
                                    color: theme.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    checckPaymentMethods == false
                                        ? Strings.PAYMENT_MODE_CASH
                                        : Strings.PAYMENT_MODE_CREDIT,
                                    style: theme.textTheme.button.copyWith(
                                      color: theme.primaryColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    onTap: () {
                                      setState(() {
                                        checckPaymentMethods = false;
                                        paymentMethod = "Cash";
                                      });
                                      selectedPaymentMethods(paymentMethod);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons
                                            .account_balance_wallet_outlined),
                                        SizedBox(width: 12),
                                        Text(Strings.PAYMENT_MODE_CASH),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      print('Credit Card');
                                      print('Credit Card');
                                      print('Credit Card');
                                      print('Credit Card');
                                      print('Credit Card');
                                      print(
                                          'Credit Card ${stripeToken.length}');

                                      setState(() {
                                        checckPaymentMethods = true;
                                        paymentMethod = "Credit Card";
                                      });
                                      stripeToken.length == 0
                                          ? createTokenWithCardForm()
                                          : print("stripeToken $stripeToken");
                                      selectedPaymentMethods(paymentMethod);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.credit_card_sharp),
                                        SizedBox(width: 12),
                                        Text(Strings.PAYMENT_MODE_CREDIT),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                            // PopupMenuButton(
                            //   onSelected: (selectedValue) {
                            //     print("PopupMenuButton Payment Method");
                            //     print(selectedValue);
                            //   },
                            //   child: Row(
                            //     children: [
                            //       Icon(
                            //         Icons.account_balance_wallet,
                            //         color: theme.primaryColor,
                            //         size: 20,
                            //       ),
                            //       SizedBox(width: 12),
                            //       Text(
                            //         Strings.PAYMENT_MODE_CASH,
                            //         style: theme.textTheme.button.copyWith(
                            //           color: theme.primaryColor,
                            //           fontSize: 15,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            //   offset: Offset(0, -144),
                            //   color: theme.backgroundColor,
                            //   shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(8)),
                            //   itemBuilder: (BuildContext context) {
                            //     return [
                            //       PopupMenuItem(
                            //         child: Row(
                            //           children: [
                            //             Icon(Icons.credit_card_sharp),
                            //             SizedBox(width: 12),
                            //             Text(Strings.PAYMENT_MODE_CASH),
                            //           ],
                            //         ),
                            //       ),
                            //       PopupMenuItem(
                            //         child: Row(
                            //           children: [
                            //             Icon(Icons.account_balance_wallet),
                            //             SizedBox(width: 12),
                            //             Text(Strings.PAYMENT_MODE_CREDIT),
                            //           ],
                            //         ),
                            //       ),
                            //     ];
                            //   },
                            // ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              color: theme.primaryColor,
                              textColor: theme.scaffoldBackgroundColor,
                              text: 'Schedule',
                              icon: Icons.calendar_today_outlined,
                              size: 18,
                              onTap: () async {
                                print('Schedule trip');

                                Provider.of<AppDataProvider>(context,
                                        listen: false)
                                    .updateCurrentRideStatus("SCHEDULE_TRIP");
                                displayToastMessage(
                                    "Scheduling Trip...", context);
                                MainScreen.dropOffTextEditingController.text =
                                    "";

                                setState(() {
                                  state = "scheduling";
                                  carRideType = "jomar-x";
                                });
                                displayRequestRideContainer();
                                _showDatePicker(context);
                                setState(() {
                                  checckPaymentMethods = false;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: CustomButton(
                              color: theme.scaffoldBackgroundColor,
                              textColor: theme.primaryColor,
                              onTap: () {
                                Provider.of<AppDataProvider>(context,
                                        listen: false)
                                    .updateCurrentRideStatus("SEARCH_DRIVER");
                                displayToastMessage(
                                    "Searching for a driver ...", context);
                                MainScreen.dropOffTextEditingController.text =
                                    "";

                                setState(() {
                                  state = "requesting";
                                  carRideType = "jomar-x";
                                });

                                displayRequestRideContainer();
                                searchNearestDriver();
                                setState(() {
                                  checckPaymentMethods = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                // : (Provider.of<AppDataProvider>(context).currentRideStatus == "SEARCH_DRIVER" ?
                //   :
                //  Container()
                )

            /*
        Container(
          height: Provider.of<AppDataProvider>(context, listen: true)
              .rideDetailsContainerHeight,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 16.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 17.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Image.asset(
                              "images/black_car.png",
                              height: 70.0,
                              width: 80.0,
                            ),
                            SizedBox(
                              width: 16.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Jomar Taxi-VIP",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: "Brand Bold",
                                  ),
                                ),
                                Text(
                                  ((Provider.of<AppDataProvider>(context).tripDirectionDetails != null)
                                      ? Provider.of<AppDataProvider>(context).tripDirectionDetails.distanceText
                                      : ''),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: Container()),
                            Column(
                              children: [
                                Text(
                                  "Suggested amount",
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontFamily: "Brand Bold",
                                  ),
                                ),
                                Text(
                                  '\CFA$suggestedAmount',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 8.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Suggest another amount",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontFamily: "Brand Bold",
                                  ),
                                ),
                              ],
                            ),
                            Expanded(child: Container()),
                            SizedBox(
                              width: 160.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(1.0),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: amountSuggestionController,
                                    decoration: InputDecoration(
                                      hintText: '$suggestedAmount',
                                      fillColor: Colors.grey[200],
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          left: 11.0, top: 8.0, bottom: 8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 5.0),
                        child: RaisedButton(
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                          ),
                          onPressed: () async {
                            displayToastMessage(
                                "Searching for a driver ...", context);

                            setState(() {
                              state = "requesting";
                              carRideType = "jomar-x";
                            });

                            displayRequestRideContainer();
                            searchNearestDriver();
                          },
                          color: Colors.black87,
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Submit",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  Icons.save,
                                  color: Colors.white,
                                  size: 26.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  height: 2.0,
                  thickness: 2.0,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.moneyCheckAlt,
                        size: 18.0,
                        color: Colors.black54,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Text("Cash"),
                      SizedBox(
                        width: 6.0,
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black54,
                        size: 16.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        */
            //    ),
            )
        : Container();
  }

  void selectedPaymentMethods(String paymentType) {
    print("paymentType $paymentType");
    Provider.of<AppDataProvider>(context, listen: false)
        .updatePaymentType(paymentType);
  }

  void RideDetailsToContinue(BuildContext context) {
    Provider.of<AppDataProvider>(context, listen: false)
        .updateCurrentRideStatus("SEARCH_DRIVER");
    displayToastMessage("Searching for a driver ...", context);

    setState(() {
      state = "requesting";
      carRideType = "jomar-x";
    });

    displayRequestRideContainer();
    searchNearestDriver();
  }

  void displayRequestRideContainer() {
    // Provider.of<AppDataProvider>(context, listen: false).updateRequestRideContainerHeight(250.0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateRideDetailsContainerHeight(0.0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateBottomPaddingOfMap(230.0);
    Provider.of<AppDataProvider>(context, listen: false).updateDrawerOpen(true);
    saveRideRequest();
  }

  Map buildRideInfoMap() {
    var pickUp =
        Provider.of<AppDataProvider>(context, listen: false).pickUpLocation;
    var dropOff =
        Provider.of<AppDataProvider>(context, listen: false).dropOffLocation;
    var noOfPassengers =
        Provider.of<AppDataProvider>(context, listen: false).noOfPassengers;
    var drivers = Provider.of<AppDataProvider>(context, listen: false)
        .nearByAvailableDriversList;
    var riderAmount = amountSuggestionController.text.isEmpty
        ? suggestedAmount.toString()
        : amountSuggestionController.text;

    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map driversList = {};
    try {
      drivers.forEach((driver) {
        Map driverDetail = {
          "driver_id": driver.key,
          "amount_suggestion": {
            "from_rider": riderAmount,
            "from_driver": "",
            "from_app": suggestedAmount
          },
          "status": ""
        };
        driversList[driver.key] = driverDetail;
      });
    } catch (error) {}
    ;

    Map rideInfoMap = {
      "suggested_drivers": driversList,
      "payment_method": paymentMethod,
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "rider_id": userCurrentInfo.id,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
      "ride_type": carRideType,
      "amount_from_rider": riderAmount,
      "selected_driver_id": "",
      "passenger_feedback": "",
      "fares": "0",
      "status": "",
      "no_of_passengers": noOfPassengers,
    };
    print("Ride Info: " + rideInfoMap.toString());
    return rideInfoMap;
  }

  void saveRideRequest() {
    var rideInfoMap = buildRideInfoMap();
    var statusOfRide;
    rideRequestRef = RideRequestRepository.setRideInfo(rideInfoMap);

    rideStreamSubscription = rideRequestRef.onValue.listen((event) async {
      // print('start listen to ride request');

      if (event.snapshot.value == null) {
        return;
      }
      // print(event.snapshot.value);

      if (event.snapshot.value["status"] == "accepted") {
        var drivers = event.snapshot.value["suggested_drivers"];
        drivers.forEach((key, value) {
          if (key == event.snapshot.value["selected_driver_id"]) {
            Provider.of<AppDataProvider>(context, listen: false)
                .setSelectedDriver(Driver.fromSnapshot(value));
          }
          // if (key == event.snapshot.value["payment_method"]) {
          //   Provider.of<AppDataProvider>(context, listen: false).setPaymentMethod(value);
          // }
          // if (key == event.snapshot.value["ride_type"]) {
          //   Provider.of<AppDataProvider>(context, listen: false).setRideType(value);
          // }
          // if (key == event.snapshot.value["amount_from_rider"]) {
          //   Provider.of<AppDataProvider>(context, listen: false).setFareAmount(value);
          // }
        });
        // if (selectedDriver["car_details"] != null) {
        //   setState(() {
        //     carDetailsDriver = event.snapshot.value["car_details"].toString();
        //   });
        // }
        // if (selectedDriver["driver_name"] != null) {
        //   setState(() {
        //     driverName = event.snapshot.value["driver_name"].toString();
        //   });
        // }
        // if (selectedDriver["driver_phone"] != null) {
        //   setState(() {
        //     driverphone = event.snapshot.value["driver_phone"].toString();
        //   });
        // }
      }
      if (event.snapshot.value["status"] == "accepted_with_condition") {
        var drivers = event.snapshot.value["suggested_drivers"];
        drivers.forEach((key, value) {
          //  if (key == event.snapshot.value["selected_driver_id"]) {
          value.forEach((key, values) {
            if (key == "status" && values == "accepted_with_condition") {
              Provider.of<AppDataProvider>(context, listen: false)
                  .setSelectedDriver(Driver.fromSnapshot(value));
            }
          });
        });
      }
      if (event.snapshot.value["status"] == "SCHEDULE_TRIP") {
        // var drivers = event.snapshot.value["suggested_drivers"];
        // drivers.forEach((key, value) {
        //   if (key == event.snapshot.value["selected_driver_id"]) {
        //     Provider.of<AppDataProvider>(context, listen: false)
        //         .setSelectedDriver(Driver.fromSnapshot(value));
        //   }
        // });
      }

      if (event.snapshot.value["payment_method"] != null) {
        Provider.of<AppDataProvider>(context, listen: false).setPaymentMethod(
            event.snapshot.value["payment_method"].toString());
      }

      if (event.snapshot.value["ride_type"] != null) {
        Provider.of<AppDataProvider>(context, listen: false)
            .setRideType(event.snapshot.value["ride_type"].toString());
      }

      if (event.snapshot.value["amount_from_rider"] != null) {
        Provider.of<AppDataProvider>(context, listen: false).setFareAmount(
            event.snapshot.value["amount_from_rider"].toString());
      }

      if (event.snapshot.value["status"] != null) {
        Provider.of<AppDataProvider>(context, listen: false)
            .updateStatusRide(event.snapshot.value["status"].toString());
        statusOfRide =
            Provider.of<AppDataProvider>(context, listen: false).statusRide;
      }

      if (event.snapshot.value["driver_location"] != null) {
        double driverLat = double.parse(
            event.snapshot.value["driver_location"]["latitude"].toString());

        double driverLng = double.parse(
            event.snapshot.value["driver_location"]["longitude"].toString());

        LatLng driverCurrentLocation = LatLng(driverLat, driverLng);

        if (statusOfRide == "accepted") {
          updateRideTimeToPickUpLoc(driverCurrentLocation);
        }
        // else if (statusOfRide == "accepted_with_condition") {
        //   updateRideTimeToPickUpLoc(driverCurrentLocation);
        // }
        else if (statusOfRide == "onride") {
          updateRideTimeToDropOffLoc(driverCurrentLocation);
        } else if (statusOfRide == "arrived") {
          setState(() {
            Provider.of<AppDataProvider>(context, listen: false).rideStatus =
                "The driver has arrived.";
          });
        }
      }

      if (event.snapshot.value["status"] == "accepted_with_condition") {
        print("accepted_with_condition  ---- 1");
        Map drivers = event.snapshot.value["suggested_drivers"];
        Provider.of<AppDataProvider>(context, listen: false)
            .clearSuggestedDrivers();
        drivers.forEach((key, value) {
          if (value["status"] == "accepted_with_condition") {
            print("accepted_with_condition  ---- 2");
            Provider.of<AppDataProvider>(context, listen: false)
                .updateSuggestedDrivers(Driver.fromSnapshot(value));
          }
        });
        displayDriverDetailsContainer();
        // Geofire.stopListener(); todo
        deleteGeofileMarkers();
      }

      if (statusOfRide == "accepted") {
        displayDriverDetailsContainer();
        // Geofire.stopListener(); todo
        deleteGeofileMarkers();
      }

      if (statusOfRide == "SCHEDULE_TRIP") {
        print('SCHEDULE_TRIP');
      }

      if (statusOfRide == "ended") {
        // print(event.snapshot.value["fares"]);
        // var paymentResponse = await PaymentServices.createCharge(
        //   tokenId: stripeToken,
        //   fareAmount: event.snapshot.value["fares"].toString(),
        // );

        // createPaymentMethodWithExistingToken()

        // print('paymentResponse $paymentResponse');

        if (event.snapshot.value["fares"] != null && !dialogShowing) {
          // ////////////////////////////////////////////////////////////////////////////////////////////////
          // StripePayment.createPaymentMethod(stripeToken);
          PaymentServices.createCharge(stripeToken);
          // ////////////////////////////////////////////////////////////////////////////////////////////////

          dialogShowing = true;
          int fare = int.parse(event.snapshot.value["fares"].toString());
          print('FARE: $fare');
          var res = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => CollectFareDialog(
              paymentMethod: "cash",
              fareAmount: fare,
              receiverPhone: driverphone,
            ),
          );

          String driverId = "";
          if (res == "close") {
            if (event.snapshot.value["selected_driver_id"] != null) {
              driverId = event.snapshot.value["selected_driver_id"].toString();
            }

            DatabaseReference driverRatingRef = FirebaseDatabase.instance
                .reference()
                .child("drivers")
                .child(driverId)
                .child("ratings");

            driverRatingRef.once().then((DataSnapshot snap) {
              if (snap.value != null) {
                double oldRatings = double.parse(snap.value.toString());
                double addRatings = oldRatings + starCounter;
                double averageRatings = addRatings / 2;
                driverRatingRef.set(averageRatings.toString());
              } else {
                driverRatingRef.set(starCounter.toString());
              }
              Provider.of<AppDataProvider>(context, listen: false)
                  .updateCurrentRideStatus("NEW");
              rideRequestRef.onDisconnect();
              rideRequestRef = null;
              rideStreamSubscription.cancel();
              rideStreamSubscription = null;
              resetApp();
            });

            /* await  Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RatingScreen(
                      driverId: driverId,
                      rideReqRef: rideRequestRef
                    )));*/

            // rideRequestRef.onDisconnect();
            // rideRequestRef = null;
            // rideStreamSubscription.cancel();
            // rideStreamSubscription = null;
            // resetApp();
          }
        }
      }
    });
  }

  void displayDriverDetailsContainer() {
    Provider.of<AppDataProvider>(context, listen: false)
        .updateRequestRideContainerHeight(0.0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateRideDetailsContainerHeight(0.0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateBottomPaddingOfMap(295.0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateDriverDetailsContainerHeight(285.0);
  }

  void updateRideTimeToPickUpLoc(LatLng driverCurrentLocation) async {
    if (isRequestingPositionDetails == false) {
      isRequestingPositionDetails = true;

      var pos =
          Provider.of<AppDataProvider>(context, listen: false).currentPosition;
      var positionUserLatLng = LatLng(pos.latitude, pos.longitude);
      var details = await LocationRepository.obtainPlaceDirectionDetails(
          driverCurrentLocation, positionUserLatLng);
      if (details == null) {
        return;
      }
      // setState(() {
      //   rideStatus = "Driver is Coming - " + details.durationText;
      // });
      Provider.of<AppDataProvider>(context, listen: false)
          .updateRideStatus("En route - " + details.durationText);

      isRequestingPositionDetails = false;
    }
  }

  void updateRideTimeToDropOffLoc(LatLng driverCurrentLocation) async {
    if (isRequestingPositionDetails == false) {
      isRequestingPositionDetails = true;

      var dropOff =
          Provider.of<AppDataProvider>(context, listen: false).dropOffLocation;
      var dropOffUserLatLng = LatLng(dropOff.latitude, dropOff.longitude);

      var details = await LocationRepository.obtainPlaceDirectionDetails(
          driverCurrentLocation, dropOffUserLatLng);
      if (details == null) {
        return;
      }
      // setState(() {
      //   rideStatus = "Going to Destination - " + details.durationText;
      // });
      Provider.of<AppDataProvider>(context, listen: false)
          .updateRideStatus("En route - " + details.durationText);

      isRequestingPositionDetails = false;
    }
  }

  void deleteGeofileMarkers() {
    // setState(() {
    //   markersSet
    //       .removeWhere((element) => element.markerId.value.contains("driver"));
    // });
  }

  void searchNearestDriver() {
    var drivers = Provider.of<AppDataProvider>(context, listen: false)
        .nearByAvailableDriversList;

    if (drivers.length == 0) {
      cancelRideRequest();
      resetApp();
      noDriverFound();
      return;
    }

    // var driver = drivers[0];

    drivers.forEach((driver) {
      driversRef
          .child(driver.key)
          .child("car_details")
          .child("type")
          .once()
          .then((DataSnapshot snap) async {
        if (await snap.value != null) {
          String carType = snap.value.toString();

          if (carType == carRideType) {
            notifyDriver(driver, suggestedAmount);
          } else {
            displayToastMessage(
                carRideType + " chauffeur non disponibles. Réessayer.",
                context);
          }
        }
      });
    });
  }

  void cancelRideRequest() {
    // rideRequestRef.remove();
    setState(() {
      state = "normal";
    });
  }

  resetApp() {
    setState(() {
      // drawerOpen = true;
      // searchContainerHeight = 300.0;
      // rideDetailsContainerHeight = 0;
      // requestRideContainerHeight = 0;
      // bottomPaddingOfMap = 230.0;

      // polylineSet.clear();
      // markersSet.clear();
      // circlesSet.clear();
      // pLineCoordinates.clear();

      // statusRide = "";
      driverName = "";
      driverphone = "";
      carDetailsDriver = "";
      // dialogShowing = false;
      // rideStatus = "Driver is Coming";
      // driverDetailsContainerHeight = 0.0;
    });
    Provider.of<AppDataProvider>(context, listen: false).updateStatusRide("");
    Provider.of<AppDataProvider>(context, listen: false)
        .updateRideTypeStatus("REFRESH");
    Provider.of<AppDataProvider>(context, listen: false).updateRideStatus("");

    Address address = Address();
    address.placeName = "";
    address.latitude = 0.0;
    address.longitude = 0.0;
    address.placeId = "";
    Provider.of<AppDataProvider>(context, listen: false)
        .updateDropOffLocationAddress(address);

    Provider.of<AppDataProvider>(context, listen: false).clearSelectedDriver();
    Provider.of<AppDataProvider>(context, listen: false)
        .clearPLineCoordinates();
    Provider.of<AppDataProvider>(context, listen: false)
        .updateSearchContainerHeight(300.0);
    Provider.of<AppDataProvider>(context, listen: false).updateDrawerOpen(true);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateRideDetailsContainerHeight(0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateRequestRideContainerHeight(0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateBottomPaddingOfMap(230.0);
    Provider.of<AppDataProvider>(context, listen: false).clearPolylines();
    Provider.of<AppDataProvider>(context, listen: false).clearMarkers();
    Provider.of<AppDataProvider>(context, listen: false).cleaCircles();
    Provider.of<AppDataProvider>(context, listen: false)
        .updateDriverDetailsContainerHeight(0.0);

    // locatePosition();
  }

  void noDriverFound() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => NoDriverAvailableDialog(),
    );
  }

  void notifyDriver(NearbyAvailableDrivers driver, double amount) async {
    driversRef.child(driver.key).child("newRide").set(rideRequestRef.key);

    driversRef
        .child(driver.key)
        .child("token")
        .once()
        .then((DataSnapshot snap) {
      if (snap.value != null) {
        // MessagesNotification.
        MessagesNotification.sendNotificationToDriver(
            snap.value.toString(), context, rideRequestRef.key, amount);
        // MessagesNotification.sendNotificationToDriverByDatabase(token, context, rideRequestRef.key);
      } else {
        return;
      }
      Provider.of<AppDataProvider>(context, listen: false).initTimeout();
      const oneSecondPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        if (state != "requesting") {
          driversRef.child(driver.key).child("newRide").set("cancelled");
          driversRef.child(driver.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 80;
          timer.cancel();
        }

        driverRequestTimeOut = driverRequestTimeOut - 1;

        driversRef.child(driver.key).child("newRide").onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driversRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 80;
            timer.cancel();
          }
          if (event.snapshot.value.toString() == "accepted_with_condition") {
            print("accepted_with_condition  ---- 3");
            driversRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 80;
            timer.cancel();
          }
        });

        if (driverRequestTimeOut == 0) {
          driversRef.child(driver.key).child("newRide").set("timeout");
          driversRef.child(driver.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 80;
          timer.cancel();

          // searchNearestDriver();
        }
      });
    });
  }
}
