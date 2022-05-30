import 'package:animation_wrappers/Animations/faded_slide_animation.dart';
import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/models/address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main_screen.dart';

class CancelRide extends StatefulWidget {
  const CancelRide({Key key}) : super(key: key);

  @override
  _CancelRideState createState() => _CancelRideState();
}

class _CancelRideState extends State<CancelRide> with TickerProviderStateMixin {
  final List<double> sizes = [120, 160, 200];

  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )
      ..repeat()
      ..addListener(() {
        setState(() {});
      });
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    // Future.delayed(Duration(seconds: 4), () => Navigator.pushNamed(context, PageRoutes.rideBookedPage));
  }

  void cancelRideRequest() {
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

    // locatePosition();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<AppDataProvider>(context).currentRideStatus ==
                "SEARCH_DRIVER" &&
            Provider.of<AppDataProvider>(context, listen: true).statusRide !=
                "accepted" &&
            Provider.of<AppDataProvider>(context, listen: true).statusRide !=
                'accepted_with_condition'
        ? Stack(
            children: [
              //  BackgroundImage(),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: sizes
                      .map((element) => CircleAvatar(
                            radius: element * _animation.value,
                            backgroundColor: Theme.of(context)
                                .primaryColor
                                .withOpacity(1 - _animation.value as double),
                          ))
                      .toList(),
                ),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                // appBar: AppBar(
                //   title: Text(
                //       (Strings.FINDING_YOUR_RIDE).toUpperCase() + '...'),
                // ),
                body: FadedSlideAnimation(
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.3),
                        child: GestureDetector(
                          onTap: () {
                            cancelRideRequest();
                            Provider.of<AppDataProvider>(context, listen: false)
                                .updateCurrentRideStatus("NEW");
                            MainScreen.dropOffTextEditingController.text = "";
                            resetApp();
                          },
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              Strings.CANCEL + '\n' + Strings.SEARCH,
                              style:
                                  Theme.of(context).textTheme.button.copyWith(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        fontSize: 15,
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  beginOffset: Offset(0, 0.3),
                  endOffset: Offset(0, 0),
                  slideCurve: Curves.linearToEaseOut,
                ),
              )
            ],
          )
        : Container();
    /* return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          color: Colors.yellow,
          boxShadow: [
            BoxShadow(
              spreadRadius: 0.5,
              blurRadius: 16.0,
              color: Colors.black54,
              offset: Offset(0.7, 0.7),
            ),
          ],
        ),
        height: Provider.of<AppDataProvider>(context, listen: false)
            .requestRideContainerHeight,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 12.0,
              ),
              SizedBox(
                width: double.infinity,
                child: ColorizeAnimatedTextKit(
                  onTap: () {
                    // print("Tap Event");
                  },
                  text: [
                    "Request a ride ...",
                    "Please wait...",
                    "Driver search ...",
                  ],
                  textStyle: TextStyle(fontSize: 32.0),
                  colors: [
                    Colors.green,
                    Colors.purple,
                    Colors.pink,
                    Colors.blue,
                    Colors.yellow,
                    Colors.red,
                  ],
                  textAlign: TextAlign.center,
                  // alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                ),
              ),
              SizedBox(
                height: 22.0,
              ),
              GestureDetector(
                onTap: () {
                  cancelRideRequest();
                  resetApp();
                },
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(26.0),
                    border: Border.all(width: 2.0, color: Colors.grey[300]),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 26.0,
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                width: double.infinity,
                child: Text(
                  "Cancel the trip",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );*/
  }
}
