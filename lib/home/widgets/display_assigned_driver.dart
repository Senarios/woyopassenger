import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:cheetah_redux/Assets/assets.dart';
import 'package:cheetah_redux/models/address.dart';
import 'package:cheetah_redux/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/models/driver.dart';
import 'package:cheetah_redux/utils/progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main_screen.dart';
import 'CustomAlertDialog.dart';

class DisplayAssignedDriverInfo extends StatefulWidget {
  const DisplayAssignedDriverInfo({Key key}) : super(key: key);

  @override
  _DisplayAssignedDriverInfoState createState() =>
      _DisplayAssignedDriverInfoState();
}

class _DisplayAssignedDriverInfoState extends State<DisplayAssignedDriverInfo> {
  bool isOpened = true;

  String driverStatus;
  String rideStatus;
  List<Driver> drivers = [];

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 2), () {
    //   showDialog(context: context, builder: (context) => RateRideDialog());
    // });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    rideStatus = Provider.of<AppDataProvider>(context, listen: true).statusRide;
    driverStatus =
        Provider.of<AppDataProvider>(context, listen: false).rideStatus;
    Driver selectedDriver =
        Provider.of<AppDataProvider>(context, listen: true).selectedDriver;

    setDrivers(context);
    return Provider.of<AppDataProvider>(context, listen: false).statusRide !=
                null &&
            Provider.of<AppDataProvider>(context, listen: false).statusRide !=
                ''
        ? Stack(
            children: [
              //    BackgroundImage(),
              Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(),
                  body: Provider.of<AppDataProvider>(context, listen: true)
                                  .statusRide ==
                              'accepted_with_condition' ||
                          Provider.of<AppDataProvider>(context, listen: true)
                                  .statusRide ==
                              'accepted' ||
                          Provider.of<AppDataProvider>(context, listen: true)
                                  .statusRide ==
                              'arrived' ||
                          Provider.of<AppDataProvider>(context, listen: true)
                                  .statusRide ==
                              'onride'
                      ? showContainer(context)
                      : Container() /* FadedSlideAnimation(
            Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onVerticalDragDown: (details) {
                        setState(() {
                          isOpened = !isOpened;
                        });
                      },
                      child: Container(
                        height: 100,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.backgroundColor,
                          borderRadius: isOpened
                              ? BorderRadius.circular(16)
                              : BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                Assets.Driver,
                                height: 72,
                                width: 72,
                              ),
                            ),
                            SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                 // 'George Smith',
                                  selectedDriver == null ? "" : selectedDriver.name,
                                  style: theme.textTheme.headline6.copyWith(
                                      fontSize: 18, letterSpacing: 1.2),
                                ),
                                Spacer(flex: 2),
                                Text(
                                 // 'Maruti Suzuki WagonR',
                                  "",
                                  style: theme.textTheme.caption
                                      .copyWith(fontSize: 12),
                                ),
                                Spacer(),
                                Text(
                                  //'DL 1 ZA 5887',
                                  selectedDriver == null ? "" : selectedDriver.car_details,
                                  style: theme.textTheme.bodyText1
                                      .copyWith(fontSize: 13.5),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                              /*  Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: AppTheme.ratingsColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '4.2',
                                        style: theme.textTheme.bodyText1
                                            .copyWith(fontSize: 12),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.star,
                                        color: AppTheme.starColor,
                                        size: 10,
                                      )
                                    ],
                                  ),
                                ),*/
                                Spacer(flex: 2),
                                Text(
                                  Strings.CURRENT_STATUS,
                                  style: theme.textTheme.caption,
                                ),
                                Spacer(),
                                Text(
                                 // Strings.ARRIVING,
                                  rideStatus,
                                  style: theme.textTheme.bodyText1
                                      .copyWith(fontSize: 13.5),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Details(isOpened ? 280 : 0),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 72,
                      color:
                      isOpened ? Colors.transparent : theme.backgroundColor,
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            icon: Icons.auto_delete,
                            text: Strings.REJECT,
                            color: theme.cardColor,
                            textColor: theme.primaryColor,
                            onTap: () {
                              print("Reject");
                             // Navigator.pop(context, "close");

                            },
                          ),
                        ),
                        Expanded(
                          child: CustomButton(
                            icon: Icons.save,
                            text: Strings.ACCEPT,
                            onTap: () {
                              print("Accept");
                              // Navigator.pop(context, "close");

                            },
                          ),
                        ),
                       /* TextButton.icon(
                                icon: Icon(Icons.call,
                                    size: 17,
                                    color: Theme.of(context).primaryColor),
                                label: Text(
                                    'Take A Photo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                onPressed: () {},
                              ),*/

                              /*buildFlatButton(
                          Icons.call,
                          Strings.CALL_NOW, () {
                          setState(() {
                            isOpened = !isOpened;
                          });
                        }
                        ),*/
                       // SizedBox(width: 10),
                      /*  buildFlatButton(Icons.close, Strings.CANCEL, () {
                          setState(() {
                            isOpened = !isOpened;
                          });
                        }),*/
                     /*   SizedBox(width: 10),
                        TextButton.icon(
                          icon: Icon(Icons.call),
                          label: Text('Take A Photo'),
                          onPressed: () {},
                        ),
                        buildFlatButton(
                            isOpened
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            isOpened ? Strings.LESS : Strings.MORE, () {
                          setState(() {
                            isOpened = !isOpened;
                          });
                        }),// */
                      ],
                    ),
                  ),
                )
              ],
            ),
            beginOffset: Offset(0, 0.3),
            endOffset: Offset(0, 0),
            slideCurve: Curves.linearToEaseOut,
          ),*/
                  ),
            ],
          )
        : Container();
    /*  return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          color: Colors.lightGreen,
          boxShadow: [
            BoxShadow(
              spreadRadius: 0.5,
              blurRadius: 16.0,
              color: Colors.black54,
              offset: Offset(0.7, 0.7),
            ),
          ],
        ),
        height: Provider.of<AppDataProvider>(context, listen: true)
            .driverDetailsContainerHeight,
        child: showContainer(context),
      ),
    );*/
  }

  void voidFunction() {
    print("Empty called");
  }

  void setDrivers(BuildContext context) {
    // print("This is setDrivers");
    drivers.clear();
    drivers.addAll(
        Provider.of<AppDataProvider>(context, listen: false).suggestedDrivers);
  }

  Widget showContainer(BuildContext context) {
    setDrivers(context);
    if (Provider.of<AppDataProvider>(context, listen: true).statusRide ==
        "accepted_with_condition") {
      if (drivers != null) {
        print("CANCEL_RIDE_WITH_CONDITION");
        //if(drivers.length == 0 &&  Provider.of<AppDataProvider>(context, listen: false).selectedDriver == null) {
        //   if(Provider.of<AppDataProvider>(context, listen: false).selectedDriver == null) {
        //   displayToastMessage("No drivers available", context);
        //   cancelRideRequest();
        //   resetApp();
        //   }
        //  else
        //     {
        return _displayAssignedDriverWithCondition();
        // return ListView.builder(
        //     itemCount: drivers.length,
        //     itemBuilder: (context, index) {
        //       return _displayAssignedDriverWithCondition(drivers[index]);
        //     });
        //   }
      }
    }
    // else if (rideStatus == "cancelled") {
    //  return Container();
    // }
    else {
      return _displayAssignedDriver();
    }
  }

  Widget _displayAssignedDriver() {
    Driver selectedDriver =
        Provider.of<AppDataProvider>(context, listen: false).selectedDriver;
    var theme = Theme.of(context);

    return FadedSlideAnimation(
      Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onVerticalDragDown: (details) {
                  setState(() {
                    isOpened = !isOpened;
                  });
                },
                child: Container(
                  height: 100,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: isOpened
                        ? BorderRadius.circular(16)
                        : BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          Assets.Driver,
                          height: 72,
                          width: 72,
                        ),
                      ),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // 'George Smith',
                            selectedDriver == null
                                ? ""
                                : selectedDriver.name.toString(),
                            style: theme.textTheme.headline6
                                .copyWith(fontSize: 18, letterSpacing: 1.2),
                          ),
                          Spacer(flex: 2),
                          Text(
                            // 'Maruti Suzuki WagonR',
                            "",
                            style:
                                theme.textTheme.caption.copyWith(fontSize: 12),
                          ),
                          Spacer(),
                          Text(
                            //'DL 1 ZA 5887',
                            selectedDriver == null
                                ? ""
                                : selectedDriver.car_details.toString(),
                            style: theme.textTheme.bodyText1
                                .copyWith(fontSize: 13.5),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          /*  Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: AppTheme.ratingsColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '4.2',
                                        style: theme.textTheme.bodyText1
                                            .copyWith(fontSize: 12),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.star,
                                        color: AppTheme.starColor,
                                        size: 10,
                                      )
                                    ],
                                  ),
                                ),*/
                          rideStatus == '' ||
                                  rideStatus == 'accepted' ||
                                  rideStatus == 'accepted_with_condition'
                              ? ElevatedButton(
                                  child: Text(Strings.CANCEL_TRIP.toString()),
                                  onPressed: () {
                                    //  cancelRideRequest();

                                    var dialog = CustomAlertDialog(
                                      title: "Ride Cancel",
                                      message:
                                          "Are you sure, do you want to Cancel Ride?",
                                      onPostivePressed: () {
                                        print(
                                            'CANCEL TRIP BTN ${rideStatus.toString()}');
                                        CancelRide();
                                        Provider.of<AppDataProvider>(context,
                                                listen: false)
                                            .updateCurrentRideStatus("NEW");
                                        resetApp();
                                        Navigator.pop(context);
                                      },
                                      positiveBtnText: 'Yes',
                                      negativeBtnText: 'No',
                                    );
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            dialog);

                                    // CancelRide();
                                    // Provider.of<AppDataProvider>(context, listen: false)
                                    //     .updateCurrentRideStatus("NEW");
                                    // resetApp();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: theme.primaryColor,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 0.02),
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                )
                              : Container(),
                          // Spacer(flex: 2),
                          // Text(
                          //   Strings.CURRENT_STATUS,
                          //   style: theme.textTheme.caption,
                          // ),
                          Spacer(),
                          Text(
                            // Strings.ARRIVING,
                            Strings.CURRENT_STATUS.toString() +
                                ' - ' +
                                rideStatus.toString(),
                            style: theme.textTheme.bodyText1
                                .copyWith(fontSize: 12.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Details(isOpened ? 280 : 0),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 72,
                color: isOpened ? Colors.transparent : theme.backgroundColor,
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      icon: Icons.call,
                      text: Strings.CALL_DRIVER,
                      onTap: () {
                        print("Accept");
                        print(selectedDriver.phone);
                        launch("tel://" + selectedDriver.phone);
                        // print(selectedDriver == null ? "" : selectedDriver.phone,);
                        // Navigator.pop(context, "close");
                      },
                    ),
                  ),
                  /* TextButton.icon(
                                icon: Icon(Icons.call,
                                    size: 17,
                                    color: Theme.of(context).primaryColor),
                                label: Text(
                                    'Take A Photo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                onPressed: () {},
                              ),*/

                  /*buildFlatButton(
                          Icons.call,
                          Strings.CALL_NOW, () {
                          setState(() {
                            isOpened = !isOpened;
                          });
                        }
                        ),*/
                  // SizedBox(width: 10),
                  /*  buildFlatButton(Icons.close, Strings.CANCEL, () {
                          setState(() {
                            isOpened = !isOpened;
                          });
                        }),*/
                  /*   SizedBox(width: 10),
                        TextButton.icon(
                          icon: Icon(Icons.call),
                          label: Text('Take A Photo'),
                          onPressed: () {},
                        ),
                        buildFlatButton(
                            isOpened
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            isOpened ? Strings.LESS : Strings.MORE, () {
                          setState(() {
                            isOpened = !isOpened;
                          });
                        }),// */
                ],
              ),
            ),
          )
        ],
      ),
      beginOffset: Offset(0, 0.3),
      endOffset: Offset(0, 0),
      slideCurve: Curves.linearToEaseOut,
    );
    /* return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 6.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                driverStatus == null ? "" : driverStatus,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 22.0,
          ),
          Divider(
            height: 2.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 22.0,
          ),
          Text(
            selectedDriver != null ? selectedDriver.car_details : "",
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            selectedDriver != null ? selectedDriver.name : "",
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            height: 22.0,
          ),
          Divider(
            height: 2.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 22.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //call button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(24.0),
                  ),
                  onPressed: () async {
                    // todo launch(('tel://${driverphone}'));
                  },
                  color: Colors.black87,
                  child: Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Appeler le chauffeur   ",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Icon(
                          Icons.call,
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
        ],
      ),
    );*/
  }

  Widget _displayAssignedDriver_OLD() {
    Driver selectedDriver =
        Provider.of<AppDataProvider>(context, listen: false).selectedDriver;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 6.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                driverStatus == null ? "" : driverStatus.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 22.0,
          ),
          Divider(
            height: 2.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 22.0,
          ),
          Text(
            selectedDriver != null ? selectedDriver.car_details.toString() : "",
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            selectedDriver != null ? selectedDriver.name.toString() : "",
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            height: 22.0,
          ),
          Divider(
            height: 2.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 22.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //call button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(24.0),
                  ),
                  onPressed: () async {
                    // todo launch(('tel://${driverphone}'));
                  },
                  color: Colors.black87,
                  child: Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Appeler le chauffeur   ",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Icon(
                          Icons.call,
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
        ],
      ),
    );
  }

  //Widget _displayAssignedDriverWithCondition(Driver driver) {
  Widget _displayAssignedDriverWithCondition() {
    Driver selectedDriver =
        Provider.of<AppDataProvider>(context, listen: false).selectedDriver;
    //  Driver selectedDriver = driver;
    print('selectedDriver-${selectedDriver}');
    print('selectedDriver-${selectedDriver.name}');
    print('selectedDriverCar-${selectedDriver.car_details}');
    print('selectedDriverPhone-${selectedDriver.phone}');
    print('selectedDriverid-${selectedDriver.id}');
    //  Driver selectedDriver = Provider.of<AppDataProvider>(context, listen: false).selectedDriver;
    var theme = Theme.of(context);

    return FadedSlideAnimation(
      Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onVerticalDragDown: (details) {
                  setState(() {
                    isOpened = !isOpened;
                  });
                },
                child: Container(
                  height: 100,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: isOpened
                        ? BorderRadius.circular(16)
                        : BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          Assets.Driver,
                          height: 72,
                          width: 72,
                        ),
                      ),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // 'George Smith',
                            selectedDriver == null
                                ? ""
                                : selectedDriver.name.toString(),
                            style: theme.textTheme.headline6
                                .copyWith(fontSize: 18, letterSpacing: 1.2),
                          ),
                          Spacer(flex: 2),
                          Text(
                            // 'Maruti Suzuki WagonR',
                            "",
                            style:
                                theme.textTheme.caption.copyWith(fontSize: 12),
                          ),
                          Spacer(),
                          Text(
                            //'DL 1 ZA 5887',
                            selectedDriver == null
                                ? ""
                                : selectedDriver.car_details.toString(),
                            style: theme.textTheme.bodyText1
                                .copyWith(fontSize: 13.5),
                          ),
                        ],
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          /*  Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: AppTheme.ratingsColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '4.2',
                                        style: theme.textTheme.bodyText1
                                            .copyWith(fontSize: 12),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.star,
                                        color: AppTheme.starColor,
                                        size: 10,
                                      )
                                    ],
                                  ),
                                ),*/
                          Spacer(flex: 2),
                          Text(
                            Strings.CURRENT_STATUS.toString(),
                            style: theme.textTheme.caption,
                          ),
                          // Spacer(),
                          SizedBox(height: 5),
                          Flexible(
                            child: Text(
                              // Strings.ARRIVING,
                              rideStatus.toString(),
                              style: theme.textTheme.bodyText1
                                  .copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Details(isOpened ? 350 : 0),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 72,
                color: isOpened ? Colors.transparent : theme.backgroundColor,
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      icon: Icons.auto_delete,
                      text: Strings.REJECT,
                      color: theme.cardColor,
                      textColor: theme.primaryColor,
                      onTap: () {
                        print("Reject");
                        // Navigator.pop(context, "close");
                        rideRequestRef
                            .child("suggested_drivers")
                            .child(selectedDriver.id)
                            .child("status")
                            .set("rejected");

                        rideRequestRef.child("status").set("");

                        Provider.of<AppDataProvider>(context, listen: false)
                            .updateStatusRide('');

                        setState(() {
                          drivers.remove(selectedDriver);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      icon: Icons.save,
                      text: Strings.ACCEPT,
                      onTap: () {
                        print("Accept");
                        // Navigator.pop(context, "close");
                        rideRequestRef
                            .child("suggested_drivers")
                            .child(selectedDriver.id)
                            .child("status")
                            .set("accepted");
                        rideRequestRef
                            .child("selected_driver_id")
                            .set(selectedDriver.id);
                        rideRequestRef.child("status").set("accepted");
                        Provider.of<AppDataProvider>(context, listen: false)
                            .setSelectedDriver(selectedDriver);
                      },
                    ),
                  ),
                  /* TextButton.icon(
                                icon: Icon(Icons.call,
                                    size: 17,
                                    color: Theme.of(context).primaryColor),
                                label: Text(
                                    'Take A Photo',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                onPressed: () {},
                              ),*/

                  /*buildFlatButton(
                          Icons.call,
                          Strings.CALL_NOW, () {
                          setState(() {
                            isOpened = !isOpened;
                          });
                        }
                        ),*/
                  // SizedBox(width: 10),
                  /*  buildFlatButton(Icons.close, Strings.CANCEL, () {
                          setState(() {
                            isOpened = !isOpened;
                          });
                        }),*/
                  /*   SizedBox(width: 10),
                        TextButton.icon(
                          icon: Icon(Icons.call),
                          label: Text('Take A Photo'),
                          onPressed: () {},
                        ),
                        buildFlatButton(
                            isOpened
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            isOpened ? Strings.LESS : Strings.MORE, () {
                          setState(() {
                            isOpened = !isOpened;
                          });
                        }),// */
                ],
              ),
            ),
          )
        ],
      ),
      beginOffset: Offset(0, 0.3),
      endOffset: Offset(0, 0),
      slideCurve: Curves.linearToEaseOut,
    );

    /* return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 6.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "The driver accepts for another amount: " +
                    currentDriver.suggestedAmount,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            height: 22.0,
          ),
          Divider(
            height: 2.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 22.0,
          ),
          Text(
            driver.car_details,
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            driver.name,
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            height: 22.0,
          ),
          Divider(
            height: 2.0,
            thickness: 2.0,
          ),
          SizedBox(
            height: 22.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //call button
              RaisedButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(24.0),
                ),
                onPressed: () async {
                  rideRequestRef
                      .child("suggested_drivers")
                      .child(currentDriver.id)
                      .child("status")
                      .set("accepted");
                  rideRequestRef
                      .child("selected_driver_id")
                      .set(currentDriver.id);
                  rideRequestRef.child("status").set("accepted");
                  Provider.of<AppDataProvider>(context, listen: false)
                      .setSelectedDriver(driver);


                },
                color: Colors.black87,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Soumettre",
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
              RaisedButton(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(24.0),
                ),
                onPressed: () async {
                  // todo launch(('tel://${driverphone}'));
                  rideRequestRef
                      .child("suggested_drivers")
                      .child(currentDriver.id)
                      .child("status")
                      .set("rejected");
                  setState(() {
                    drivers.remove(driver);
                  });
                },
                color: Colors.black87,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Refuser",
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
            ],
          ),
        ],
      ),
    );*/
  }

  void CancelRide() {
    rideRequestRef.child("status").set("CANCELLED_BY_PASSENGER");
    rideRequestRef.child('fares').set('0');
  }

  void cancelRideRequest() {
    // Provider.of<AppDataProvider>(context, listen: false)
    //     .updateStatusRide("cancelled");
    rideRequestRef.remove();
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
      //
      // polylineSet.clear();
      // markersSet.clear();
      // circlesSet.clear();
      // pLineCoordinates.clear();
      //
      // statusRide = "";
      driverName = "";
      driverphone = "";
      carDetailsDriver = "";
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

    Provider.of<AppDataProvider>(context, listen: false).statusRide = '';
    Provider.of<AppDataProvider>(context, listen: false).currentRideStatus = '';

    // locatePosition();
  }

  Widget buildFlatButton(IconData icon, String text, [Function onTap]) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap as void Function() ?? () {},
        style: TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        icon: Icon(
          icon,
          size: 17,
          color: Theme.of(context).primaryColor,
        ),
        label: Expanded(
          child: Text(
            text.toString(),
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(fontSize: 13.5, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class Details extends StatefulWidget {
  final double height;

  Details(this.height);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    Address pickUpLocation =
        Provider.of<AppDataProvider>(context, listen: false).pickUpLocation;
    Address dropOffLocation =
        Provider.of<AppDataProvider>(context, listen: false).dropOffLocation;
    String lrideStatus =
        Provider.of<AppDataProvider>(context, listen: false).rideStatus == null
            ? ""
            : Provider.of<AppDataProvider>(context, listen: false).rideStatus;
    String paymentMethod =
        Provider.of<AppDataProvider>(context, listen: false).paymentMethod;
    String rideType =
        Provider.of<AppDataProvider>(context, listen: false).rideType;
    String fareAmount =
        Provider.of<AppDataProvider>(context, listen: false).fareAmount;

    Driver lSelectedDriver =
        Provider.of<AppDataProvider>(context, listen: false).selectedDriver;

    print("pickUpLocation${pickUpLocation}");
    print("dropOffLocation${dropOffLocation}");
    print("lrideStatus${lrideStatus}");
    print("paymentMethod${paymentMethod}");
    print("rideType${rideType}");
    print("fareAmount${fareAmount}");
    print("New fareAmount ${lSelectedDriver.suggestedAmount}");

    var theme = Theme.of(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: widget.height,
      child: ListView(
        children: [
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    Strings.RIDE_INFO.toString(),
                    style: theme.textTheme.headline6
                        .copyWith(color: theme.hintColor, fontSize: 16.5),
                  ),
                  trailing: Text(lrideStatus.toString(), //'08 km',
                      style:
                          theme.textTheme.headline6.copyWith(fontSize: 16.5)),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(
                    Icons.location_on,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    //  '2nd ave, World Trade Center',
                    pickUpLocation == null
                        ? ""
                        : pickUpLocation.placeName.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: Icon(
                    Icons.navigation,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                  title: Text(
                    // '1124, Golden Point Street',
                    dropOffLocation == null
                        ? ""
                        : dropOffLocation.placeName.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                buildRowItem(
                    theme,
                    Strings.PAYMENT_VIA,
                    //Strings.PAYMENT_MODE_CASH,
                    paymentMethod == null ? "" : paymentMethod,
                    Icons.account_balance_wallet),
                Spacer(),
                buildRowItem(
                    theme,
                    Strings.RIDE_FARE,
                    //'\$ 40.50',
                    lSelectedDriver.suggestedAmount.toString() == null ||
                            lSelectedDriver.suggestedAmount.toString() == ''
                        ? fareAmount == null
                            ? ''
                            : '\$' + fareAmount
                        : '\$' + lSelectedDriver.suggestedAmount,
                    Icons.account_balance_wallet),
                Spacer(),
                buildRowItem(
                    theme,
                    Strings.RIDE_TYPE,
                    //Strings.PRIVATE,
                    rideType == null ? "" : rideType,
                    Icons.drive_eta),
              ],
            ),
          ),
          SizedBox(height: 12),
          lSelectedDriver.suggestedAmount.toString() != ''
              // lSelectedDriver.suggestedAmount.toString() != ''
              ? Container(
                  height: 50,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'The Driver accepted for another Amount: \$' +
                        lSelectedDriver.suggestedAmount,
                    style: theme.textTheme.bodyText1.copyWith(fontSize: 13.5),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Expanded buildRowItem(
      ThemeData theme, String title, String subtitle, IconData icon) {
    return Expanded(
      flex: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toString(),
            style: theme.textTheme.headline6
                .copyWith(color: theme.hintColor, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                icon,
                color: theme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                subtitle.toString(),
                style: theme.textTheme.headline6.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
