import 'dart:async';

import 'package:animation_wrappers/Animations/faded_scale_animation.dart';
import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:cheetah_redux/Assistants/assistantMethods.dart';
import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/widgets/app_drawer.dart';
import 'package:cheetah_redux/home/widgets/cancel_ride.dart';
import 'package:cheetah_redux/home/widgets/display_assigned_driver.dart';
import 'package:cheetah_redux/home/widgets/ride_details.dart';
import 'package:cheetah_redux/home/widgets/search_ride.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/models/address.dart';
import 'package:cheetah_redux/models/nearby_available_drivers.dart';
import 'package:cheetah_redux/models/place_predictitions.dart';
import 'package:cheetah_redux/network/http_handler.dart';
import 'package:cheetah_redux/network/location_repository.dart';
import 'package:cheetah_redux/utils/divider.dart';
import 'package:cheetah_redux/utils/entry_field.dart';
import 'package:cheetah_redux/utils/google_map_key.dart';
import 'package:cheetah_redux/utils/progress_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  static TextEditingController dropOffTextEditingController =
      TextEditingController();

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController noOfPassengerController = TextEditingController();

  static List<PlacePredictions> placePredictionList = [];

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  static final CameraPosition cameraPosition = CameraPosition(
    target: LatLng(5.3364, -4.0266),
    zoom: 14.4746,
  );

  bool isFavoriteAddress = false;
  bool isOneClickMapPopulated = false;
  bool isHhistoryLoaded = false;

  bool nearbyAvailableDriverKeysLoaded = false;
  BitmapDescriptor nearByIcon;
  // List<NearbyAvailableDrivers> availableDrivers;

  bool isRequestingPositionDetails = false;
  final geo = GeoFlutterFire();
  var availDriversCollectionReference;

  @override
  void initState() {
    super.initState();
    print('HOME');

    LocationRepository.getCurrentOnlineUserInfo();
    noOfPassengerController.text = "1";
    Future.delayed(const Duration(milliseconds: 500), () {
      Provider.of<AppDataProvider>(context, listen: false)
          .updateCurrentRideStatus("NEW");

      if (!isHhistoryLoaded) {
        AssistantMethods.retrieveHistoryInfo(context);
        setState(() {
          isHhistoryLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    createIconMarker();

    String placeAddress =
        Provider.of<AppDataProvider>(context).pickUpLocation?.placeName ?? "";
    pickUpTextEditingController.text = placeAddress;
    // noOfPassengerController.text = "1";

    if (Provider.of<AppDataProvider>(context).rideTypeStatus == "") {
      setState(() {
        isOneClickMapPopulated = false;
      });
    }

    if (Provider.of<AppDataProvider>(context).rideTypeStatus == "REFRESH") {
      print('REFRESH');
      Provider.of<AppDataProvider>(context).updateRideTypeStatus("");
      MainScreen.dropOffTextEditingController.clear();
      print('REFRESH DONE');
    }

    if (Provider.of<AppDataProvider>(context).rideTypeStatus ==
        "ONE_CLICK_RIDE") {
      MainScreen.dropOffTextEditingController.text =
          Provider.of<AppDataProvider>(context).dropOffLocation?.placeName ??
              "";
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!isOneClickMapPopulated) {
          setState(() {
            isOneClickMapPopulated = true;
          });
          // getPlaceDirection(context);
          getPlaceDirection(context).then((value) {
            Provider.of<AppDataProvider>(context, listen: false)
                .updateCurrentRideStatus("SEARCH_DRIVER_ONE_CLICK");
            MainScreen.dropOffTextEditingController.text = "";
          });

          //  RideDetailsToContinue(context);
        }

        // Provider.of<AppDataProvider>(context, listen: false).updateCurrentRideStatus("LOCATION_SELECTED");
        //  Future.delayed(const Duration(milliseconds: 500), ()
        //  {
        //    displayToastMessage("Searching for a driver ...", context);
        //   MainScreen.dropOffTextEditingController.text = "";

        //  });

        //  }
      });
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
            Provider.of<AppDataProvider>(context).currentRideStatus == "NEW" ||
                    Provider.of<AppDataProvider>(context).currentRideStatus ==
                        "CANCELLED_BY_PASSENGER"||
                    Provider.of<AppDataProvider>(context).currentRideStatus ==
                        "SCHEDULE_TRIP" ||
                    Provider.of<AppDataProvider>(context).currentRideStatus ==
                        "ONE_CLICK_RIDE"
                ? Strings.BOOK_YOUR_RIDE
                : (Provider.of<AppDataProvider>(context).currentRideStatus ==
                        "SEARCH_DRIVER"
                    ? Strings.FINDING_YOUR_RIDE.toUpperCase() + '...'
                    : "")),
      ),
      drawer: AppDrawer(
          //  userName: userCurrentInfo?.name,
          //   phoneNumber: userCurrentInfo?.phone,
          ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
                bottom: Provider.of<AppDataProvider>(context, listen: true)
                    .bottomPaddingOfMap,
                top: 25.0),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: cameraPosition,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines:
                Provider.of<AppDataProvider>(context, listen: true).polylineSet,
            markers:
                Provider.of<AppDataProvider>(context, listen: true).markersSet,
            circles:
                Provider.of<AppDataProvider>(context, listen: true).circlesSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              newGoogleMapController.setMapStyle(
                '[ { "elementType": "geometry", "stylers": [ { "color": "#212121" } ] }, { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] }, { "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "elementType": "labels.text.stroke", "stylers": [ { "color": "#212121" } ] }, { "featureType": "administrative", "elementType": "geometry", "stylers": [ { "color": "#757575" } ] }, { "featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [ { "color": "#9e9e9e" } ] }, { "featureType": "administrative.land_parcel", "stylers": [ { "visibility": "off" } ] }, { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [ { "color": "#bdbdbd" } ] }, { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#181818" } ] }, { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "poi.park", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1b1b1b" } ] }, { "featureType": "road", "elementType": "geometry.fill", "stylers": [ { "color": "#2c2c2c" } ] }, { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#8a8a8a" } ] }, { "featureType": "road.arterial", "elementType": "geometry", "stylers": [ { "color": "#373737" } ] }, { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#3c3c3c" } ] }, { "featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [ { "color": "#4e4e4e" } ] }, { "featureType": "road.local", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "transit", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#000000" } ] }, { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#3d3d3d" } ] } ]',
              );
              Provider.of<AppDataProvider>(context, listen: false)
                  .updateBottomPaddingOfMap(340.0);

              locatePosition();
            },
          ),

          //HamburgerButton for Drawer
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Provider.of<AppDataProvider>(context).currentRideStatus ==
                        "NEW" ||
                    Provider.of<AppDataProvider>(context).currentRideStatus ==
                        "SCHEDULE_TRIP"||
                    Provider.of<AppDataProvider>(context).currentRideStatus ==
                        "CANCELLED_BY_PASSENGER" ||
                    Provider.of<AppDataProvider>(context).currentRideStatus ==
                        "ONE_CLICK_RIDE" ||
                    Provider.of<AppDataProvider>(context).currentRideStatus ==
                        "LOCATION_SELECTED"
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    // width: 100.0,
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      //  mainAxisSize: MainAxisSize.min,
                      children: [
                        EntryField(
                          showUnderline: false,
                          hint: Strings.ENTER_SOURCE,
                          prefixIcon: Icons.location_on,
                          controller: pickUpTextEditingController,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: EntryField(
                                showUnderline: false,
                                hint: Strings.ENTER_DESTINATION,
                                prefixIcon: Icons.navigation,
                                onChanged: findPlace,
                                controller:
                                    MainScreen.dropOffTextEditingController,
                              ),
                            ),
                            Container(
                              //  height: 30.0,
                              //   width: 30.0,
                              child: FlatButton(
                                child: Icon(
                                  Icons.favorite,
                                  color: Provider.of<AppDataProvider>(context)
                                                  .rideTypeStatus ==
                                              "ONE_CLICK_RIDE" ||
                                          isFavoriteAddress
                                      ? Colors.red
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  print(Provider.of<AppDataProvider>(context,
                                          listen: false)
                                      .dropOffLocation);
                                  setState(() {
                                    isFavoriteAddress =
                                        true; //!isFavoriteAddress;
                                  });

                                  SaveFavoriteLocation(
                                      Provider.of<AppDataProvider>(context,
                                              listen: false)
                                          .dropOffLocation);
                                  displayToastMessage(
                                      "Favorite address added ...", context);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        (Provider.of<AppDataProvider>(context)
                                    .currentRideStatus ==
                                "LOCATION_SELECTED")
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 30.0,
                                  ),
                                  Text(Strings.NO_OF_PASSENGERS, //'08 km',
                                      style: theme.textTheme.headline6
                                          .copyWith(fontSize: 16.5)),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: EntryField(
                                      showUnderline: false,
                                      hint: Strings.NO_OF_PASSENGERS,
                                      onChanged: noOfPassengers,
                                      controller: noOfPassengerController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                width: 0.01,
                                height: 0.01,
                              ),
                        (placePredictionList.length > 0)
                            ? Container(
                                width: 350.0,
                                height: 300.0,
                                decoration: BoxDecoration(
                                  color: theme.backgroundColor,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 0.0),
                                  child: ListView.separated(
                                    padding: EdgeInsets.all(0.0),
                                    itemBuilder: (context, index) {
                                      return PredictionTile(
                                        placePredictions:
                                            placePredictionList[index],
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            DividerWidget(),
                                    itemCount: placePredictionList.length,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                  ),
                                ),
                              )
                            : Container(
                                width: 0.01,
                                height: 0.01,
                                // decoration: BoxDecoration(
                                //   color: Colors.orange,
                                // ),
                                //child: Text(" ")
                              ),
                      ],
                    ),
                  )
                : Container(),
          ),

          // //Search Ui
          //    SearchRide(),

          // //Ride Details Ui
          RideDetails(),

          // //Cancel Ui
          CancelRide(),

          // //Display Assigned Driver Info
          DisplayAssignedDriverInfo(),
        ],
      ),
    );
  }

  void SaveFavoriteLocation(Address location) {
    var location_name = {
      "latitude": location.latitude,
      "longitude": location.longitude,
      "placeName": location.placeName,
      "placeId": location.placeId,
    };
    usersRef.child(firebaseUser.uid).update({
      "one_click_pickup": location_name,
    });
  }

  void locatePosition() async {
    var pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Provider.of<AppDataProvider>(context, listen: false)
        .updateCurrentPosition(pos);

    // Update position to google map
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(
        new CameraPosition(
            target: LatLng(pos.latitude, pos.longitude), zoom: 14)));

    // Get current position address
    await LocationRepository.searchCoordinateAddress(pos, context);

    listenToAvailableDrivers();

    //
    // uName = userCurrentInfo.name;
    //
    // LocationRepository.retrieveHistoryInfo(context);
  }

  void listenToAvailableDrivers() async {
    var pos =
        Provider.of<AppDataProvider>(context, listen: false).currentPosition;
    double radius = 5;
    List offlineDrivers = [];
    var availDriversCollectionReference =
        FirebaseFirestore.instance.collection("availableDrivers");
    GeoFirePoint center =
        geo.point(latitude: pos.latitude, longitude: pos.longitude);

    availDriversCollectionReference.snapshots().listen((event) {
      offlineDrivers.clear();
      Provider.of<AppDataProvider>(context, listen: false)
          .nearByAvailableDriversList
          .forEach((element) {
        if (!event.docs.map((e) => e.id).contains(element.key)) {
          offlineDrivers.add(element);
        }
      });

      offlineDrivers.forEach((element) {
        Provider.of<AppDataProvider>(context, listen: false)
            .nearByAvailableDriversList
            .remove(element);
      });
    });

    Stream<List<DocumentSnapshot>> availableDriversStream = geo
        .collection(collectionRef: availDriversCollectionReference)
        .within(center: center, radius: radius, field: 'position');

    availableDriversStream.listen((List<DocumentSnapshot> documentList) {
      documentList.forEach((DocumentSnapshot document) {
        Map<String, dynamic> snapData = document.data();
        final GeoPoint point = snapData['position']['geopoint'];
        // final String geohash = snapData['position']['geohash'];

        var nearbyAvailableDrivers = NearbyAvailableDrivers();
        nearbyAvailableDrivers.key = document.id;
        nearbyAvailableDrivers.latitude = point.latitude;
        nearbyAvailableDrivers.longitude = point.longitude;

        Provider.of<AppDataProvider>(context, listen: false)
            .updateDriverNearbyLocation(nearbyAvailableDrivers);

        updateAvailableDriversOnMap();
      });
    });
  }

  void updateAvailableDriversOnMap() {
    Provider.of<AppDataProvider>(context, listen: false).clearMarkers();
    var drivers = Provider.of<AppDataProvider>(context, listen: false)
        .nearByAvailableDriversList;
    Set<Marker> tMakers = Set<Marker>();
    for (NearbyAvailableDrivers driver in drivers) {
      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: LatLng(driver.latitude, driver.longitude),
        icon: nearByIcon,
        //rotation: AssistantMethods.createRandomNumber(360),
      );

      tMakers.add(marker);
    }

    Provider.of<AppDataProvider>(context, listen: false).updateMarkers(tMakers);
  }

  void createIconMarker() {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios.png")
          .then((value) {
        nearByIcon = value;
      });
    }
  }

  void noOfPassengers(String noOfPassengers) {
    print("noOfPassengers=${noOfPassengers}=");

    var iNoOfPassengers = int.parse(noOfPassengers);
    if (noOfPassengers == '') {
      noOfPassengerController.text = "1";
      iNoOfPassengers = 1;
    }
    if (iNoOfPassengers > 0 && iNoOfPassengers <= 4) {
      Provider.of<AppDataProvider>(context, listen: false)
          .updateNoOfPassengers(noOfPassengers);
    } else {
      displayToastMessage("No of passengers must be less than 5", context);
      noOfPassengerController.text = "1";
      Provider.of<AppDataProvider>(context, listen: false)
          .updateNoOfPassengers("1");
    }
  }

  void findPlace(String placeName) async {
    print("findPlace ${placeName}");
    if (placeName.length > 1) {
      var res = await HttpHandler.get(
          'maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': placeName,
        'key': googleMapKey,
        'sessiontoken': '1234567890',
        //'components': 'country:us'
        // 'components': 'country:ci'
      });

      if (res == "failed") {
        return;
      }

      if (res["status"] == "OK") {
        var predictions = res["predictions"];

        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        print(placesList);
        print("findPlaceList ${placesList.length} ");
        setState(() {
          placePredictionList = placesList;
        });
      }
    }
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
      // rideStatus = "Driver is Coming";
      // driverDetailsContainerHeight = 0.0;
    });
    Provider.of<AppDataProvider>(context, listen: false).updateStatusRide("");
    Provider.of<AppDataProvider>(context, listen: false)
        .updateRideStatus("Driver is Coming");

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

  Future<void> getPlaceDirection(context) async {
    var initialPos =
        Provider.of<AppDataProvider>(context, listen: false).pickUpLocation;
    var finalPos =
        Provider.of<AppDataProvider>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ),);

    var details = await LocationRepository.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    // setState(() {
    //   tripDirectionDetails = details;
    // });
    Provider.of<AppDataProvider>(context, listen: false)
        .updateTripDirectionDetails(details);

    Navigator.pop(context);

    // print("This is Encoded Points ::");
    // print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    // pLineCoordinates.clear();
    Provider.of<AppDataProvider>(context, listen: false)
        .clearPLineCoordinates();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        // pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        Provider.of<AppDataProvider>(context, listen: false).addPLineCoordinate(
            LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    Provider.of<AppDataProvider>(context, listen: false).clearPolylines();
    // polylineSet.clear();

    // setState(() {
    //   Polyline polyline = Polyline(
    //     color: Colors.pink,
    //     polylineId: PolylineId("PolylineID"),
    //     jointType: JointType.round,
    //     points: pLineCoordinates,
    //     width: 5,
    //     startCap: Cap.roundCap,
    //     endCap: Cap.roundCap,
    //     geodesic: true,
    //   );
    //
    //   polylineSet.add(polyline);
    // });
    Polyline polyline = Polyline(
      color: Colors.pink,
      polylineId: PolylineId("PolylineID"),
      jointType: JointType.round,
      points:
          Provider.of<AppDataProvider>(context, listen: false).pLineCoordinates,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
    Provider.of<AppDataProvider>(context, listen: false).addPolylines(polyline);

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "My position"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Destination"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    Provider.of<AppDataProvider>(context, listen: false)
        .addMarker(pickUpLocMarker);
    Provider.of<AppDataProvider>(context, listen: false)
        .addMarker(dropOffLocMarker);
    // setState(() {
    //   markersSet.add(pickUpLocMarker);
    //   markersSet.add(dropOffLocMarker);
    // });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    Provider.of<AppDataProvider>(context, listen: false)
        .addCircle(pickUpLocCircle);
    Provider.of<AppDataProvider>(context, listen: false)
        .addCircle(dropOffLocCircle);
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;

  PredictionTile({Key key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if(Provider.of<AppDataProvider>(context).currentRideStatus == "ONE_CLICK_RIDE"){
    //   print("currentRideStatus 436");
    //   getPlaceAddressDetails(Provider.of<AppDataProvider>(context).dropOffLocation.placeId, context);
    // }

    var theme = Theme.of(context);
    return FlatButton(
      padding: EdgeInsets.all(0.0),
      onPressed: () {
        getPlaceAddressDetails(placePredictions.place_id, context);
        //  _MainScreenState.placePredictionList.clear();
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.backgroundColor,
        ),
        child: Column(
          children: [
            SizedBox(
              width: 10.0,
            ),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                        placePredictions.main_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        placePredictions.secondary_text,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Searching, please wait...",
            ));

    var res = await HttpHandler.get(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {'place_id': placeId, 'key': googleMapKey});

    Navigator.pop(context);

    if (res == "failed") {
      return;
    }

    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];
      MainScreen.dropOffTextEditingController.text = address.placeName;

      Provider.of<AppDataProvider>(context, listen: false)
          .updateDropOffLocationAddress(address);
      // print("This is Drop Off Location :: ");
      // print(address.placeName);
      displayRideDetailsContainer(context);
      //  Navigator.pop(context, "obtainDirection");
    }
  }

  void displayRideDetailsContainer(context) async {
    await getPlaceDirection(context);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateCurrentRideStatus("LOCATION_SELECTED");

    Provider.of<AppDataProvider>(context, listen: false)
        .updateSearchContainerHeight(0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateRideDetailsContainerHeight(300.0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateBottomPaddingOfMap(360.0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateDrawerOpen(false);
  }

  Future<void> getPlaceDirection(context) async {
    var initialPos =
        Provider.of<AppDataProvider>(context, listen: false).pickUpLocation;
    var finalPos =
        Provider.of<AppDataProvider>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));

    var details = await LocationRepository.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    // setState(() {
    //   tripDirectionDetails = details;
    // });
    Provider.of<AppDataProvider>(context, listen: false)
        .updateTripDirectionDetails(details);

    Navigator.pop(context);

    // print("This is Encoded Points ::");
    // print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    // pLineCoordinates.clear();
    Provider.of<AppDataProvider>(context, listen: false)
        .clearPLineCoordinates();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        // pLineCoordinates.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        Provider.of<AppDataProvider>(context, listen: false).addPLineCoordinate(
            LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    Provider.of<AppDataProvider>(context, listen: false).clearPolylines();
    // polylineSet.clear();

    // setState(() {
    //   Polyline polyline = Polyline(
    //     color: Colors.pink,
    //     polylineId: PolylineId("PolylineID"),
    //     jointType: JointType.round,
    //     points: pLineCoordinates,
    //     width: 5,
    //     startCap: Cap.roundCap,
    //     endCap: Cap.roundCap,
    //     geodesic: true,
    //   );
    //
    //   polylineSet.add(polyline);
    // });
    Polyline polyline = Polyline(
      color: Colors.pink,
      polylineId: PolylineId("PolylineID"),
      jointType: JointType.round,
      points:
          Provider.of<AppDataProvider>(context, listen: false).pLineCoordinates,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
    Provider.of<AppDataProvider>(context, listen: false).addPolylines(polyline);

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "My position"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: finalPos.placeName, snippet: "Destination"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    Provider.of<AppDataProvider>(context, listen: false)
        .addMarker(pickUpLocMarker);
    Provider.of<AppDataProvider>(context, listen: false)
        .addMarker(dropOffLocMarker);
    // setState(() {
    //   markersSet.add(pickUpLocMarker);
    //   markersSet.add(dropOffLocMarker);
    // });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    Provider.of<AppDataProvider>(context, listen: false)
        .addCircle(pickUpLocCircle);
    Provider.of<AppDataProvider>(context, listen: false)
        .addCircle(dropOffLocCircle);

    _MainScreenState.placePredictionList.clear();
    // setState(() {
    //   circlesSet.add(pickUpLocCircle);
    //   circlesSet.add(dropOffLocCircle);
    // });
  }
}
