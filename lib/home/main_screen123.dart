import 'dart:async';

import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/widgets/app_drawer.dart';
import 'package:cheetah_redux/home/widgets/cancel_ride.dart';
import 'package:cheetah_redux/home/widgets/display_assigned_driver.dart';
import 'package:cheetah_redux/home/widgets/ride_details.dart';
import 'package:cheetah_redux/home/widgets/search_ride.dart';
import 'package:cheetah_redux/models/nearby_available_drivers.dart';
import 'package:cheetah_redux/network/location_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen11 extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen11> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  static final CameraPosition cameraPosition = CameraPosition(
    target: LatLng(5.3364, -4.0266),
    zoom: 14.4746,
  );

  bool nearbyAvailableDriverKeysLoaded = false;
  BitmapDescriptor nearByIcon;
  // List<NearbyAvailableDrivers> availableDrivers;

  bool isRequestingPositionDetails = false;
  final geo = GeoFlutterFire();
  var availDriversCollectionReference;

  @override
  void initState() {
    super.initState();
    LocationRepository.getCurrentOnlineUserInfo();

  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: AppDrawer(
      //  userName: userCurrentInfo?.name,
      //  phoneNumber: userCurrentInfo?.phone,
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
              newGoogleMapController.setMapStyle('[ { "elementType": "geometry", "stylers": [ { "color": "#212121" } ] }, { "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] }, { "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "elementType": "labels.text.stroke", "stylers": [ { "color": "#212121" } ] }, { "featureType": "administrative", "elementType": "geometry", "stylers": [ { "color": "#757575" } ] }, { "featureType": "administrative.country", "elementType": "labels.text.fill", "stylers": [ { "color": "#9e9e9e" } ] }, { "featureType": "administrative.land_parcel", "stylers": [ { "visibility": "off" } ] }, { "featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [ { "color": "#bdbdbd" } ] }, { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#181818" } ] }, { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "poi.park", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1b1b1b" } ] }, { "featureType": "road", "elementType": "geometry.fill", "stylers": [ { "color": "#2c2c2c" } ] }, { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#8a8a8a" } ] }, { "featureType": "road.arterial", "elementType": "geometry", "stylers": [ { "color": "#373737" } ] }, { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#3c3c3c" } ] }, { "featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [ { "color": "#4e4e4e" } ] }, { "featureType": "road.local", "elementType": "labels.text.fill", "stylers": [ { "color": "#616161" } ] }, { "featureType": "transit", "elementType": "labels.text.fill", "stylers": [ { "color": "#757575" } ] }, { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#000000" } ] }, { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#3d3d3d" } ] } ]');
              Provider.of<AppDataProvider>(context, listen: false)
                  .updateBottomPaddingOfMap(300.0);

              locatePosition();
            },
          ),

          //HamburgerButton for Drawer
          Positioned(
            top: 36.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (Provider.of<AppDataProvider>(context, listen: false)
                    .drawerOpen) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (Provider.of<AppDataProvider>(context, listen: true)
                        .drawerOpen)
                        ? Icons.menu
                        : Icons.close,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),

          // //Search Ui
          SearchRide(),

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
    List offlineDrivers=[];
    var availDriversCollectionReference =
    FirebaseFirestore.instance.collection("availableDrivers");
    GeoFirePoint center =
    geo.point(latitude: pos.latitude, longitude: pos.longitude);

    availDriversCollectionReference.snapshots().listen((event) {

      offlineDrivers.clear();
      Provider.of<AppDataProvider>(context, listen: false)
          .nearByAvailableDriversList.forEach((element) {
        if(!event.docs.map((e) => e.id).contains(element.key))
        {
          offlineDrivers.add(element);
        }
      });

      offlineDrivers.forEach((element) {
        Provider.of<AppDataProvider>(context, listen: false).nearByAvailableDriversList.remove(element);
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
}
