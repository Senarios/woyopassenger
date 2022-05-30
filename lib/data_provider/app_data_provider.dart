import 'dart:core';

import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/models/address.dart';
import 'package:cheetah_redux/models/direction_details.dart';
import 'package:cheetah_redux/models/driver.dart';
import 'package:cheetah_redux/models/history.dart';
import 'package:cheetah_redux/models/nearby_available_drivers.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppDataProvider extends ChangeNotifier {
  Address pickUpLocation, dropOffLocation;

  String earnings = "50";
  int countTrips = 0;
  int countHistoryTrips = 0;

  List<String> historyTripKeys = [];
  List<History> historyTripDataList = [];

  String currentUserName;
  String paymentMethod;
  String rideType;
  String fareAmount;

  void updateHistoryTripData(History historyTrip) {
    historyTripDataList.add(historyTrip);
    notifyListeners();
  }

  void updateHistoryTripCounter(int historytripCounter) {
    countHistoryTrips = historytripCounter;
    print('update');
    notifyListeners();
  }

  void updateHistoryTripKeys(List<String> newKeys) {
    historyTripKeys = newKeys;
    notifyListeners();
  }

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

  void updateCurrentUserName(String userName) {
    currentUserName = userName;
    notifyListeners();
  }

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  Set<Polyline> polylineSet = {};
  DirectionDetails tripDirectionDetails;

  void clearMarkers() {
    markersSet.clear();
    notifyListeners();
  }

  void addMarker(Marker marker) {
    markersSet.add(marker);
    notifyListeners();
  }

  void updateMarkers(Set<Marker> markers) {
    markersSet = markers;
    notifyListeners();
  }

  void updateTripDirectionDetails(DirectionDetails tripDetails) {
    tripDirectionDetails = tripDetails;
    notifyListeners();
  }

  void clearPolylines() {
    polylineSet.clear();
    notifyListeners();
  }

  void addPolylines(Polyline polylines) {
    polylineSet.add(polylines);
    notifyListeners();
  }

  void updatePolylines(Set<Polyline> polylines) {
    polylineSet = polylines;
    notifyListeners();
  }

  void cleaCircles() {
    circlesSet.clear();
    notifyListeners();
  }

  void addCircle(Circle circle) {
    circlesSet.add(circle);
    notifyListeners();
  }

  void updateCircles(Set<Circle> circles) {
    circlesSet = circles;
    notifyListeners();
  }

  double bottomPaddingOfMap = 0;
  void updateBottomPaddingOfMap(double bottomPadding) {
    bottomPaddingOfMap = bottomPadding;
    notifyListeners();
  }

  double requestRideContainerHeight = 0;
  void updateRequestRideContainerHeight(double requestRideContainerH) {
    requestRideContainerHeight = requestRideContainerH;
    notifyListeners();
  }

  double rideDetailsContainerHeight = 0;
  void updateRideDetailsContainerHeight(double rideDetailsContainerH) {
    rideDetailsContainerHeight = rideDetailsContainerH;
    notifyListeners();
  }

  double driverDetailsContainerHeight = 0;
  void updateDriverDetailsContainerHeight(double driverDetailsContainerH) {
    driverDetailsContainerHeight = driverDetailsContainerH;
    notifyListeners();
  }

  bool drawerOpen = false;
  void updateDrawerOpen(bool isDrawerOpen) {
    drawerOpen = isDrawerOpen;
    notifyListeners();
  }

  Position currentPosition;
  void updateCurrentPosition(Position pos) {
    currentPosition = pos;
    notifyListeners();
  }

  double searchContainerHeight = 300.0;
  void updateSearchContainerHeight(double height) {
    searchContainerHeight = height;
    notifyListeners();
  }

  List<LatLng> pLineCoordinates = [];
  void updatePLineCoordinates(List<LatLng> coordinates) {
    pLineCoordinates = coordinates;
    notifyListeners();
  }

  void clearPLineCoordinates() {
    pLineCoordinates.clear();
    notifyListeners();
  }

  void addPLineCoordinate(LatLng coordinate) {
    pLineCoordinates.add(coordinate);
    notifyListeners();
  }

  List<NearbyAvailableDrivers> nearByAvailableDriversList = [];
  void removeDriverFromList(String key) {
    int index =
        nearByAvailableDriversList.indexWhere((element) => element.key == key);
    nearByAvailableDriversList.removeAt(index);
    notifyListeners();
  }

  removeDriverFromPos(int pos) {
    nearByAvailableDriversList.removeAt(0);
    notifyListeners();
  }

  void updateDriverNearbyLocation(NearbyAvailableDrivers driver) {
    int index = nearByAvailableDriversList
        .indexWhere((element) => element.key == driver.key);
    if (index == -1) {
      nearByAvailableDriversList.add(driver);
    } else {
      nearByAvailableDriversList[index].latitude = driver.latitude;
      nearByAvailableDriversList[index].longitude = driver.longitude;
    }
    notifyListeners();
  }

  void clearDriversList() {
    nearByAvailableDriversList.clear();
    notifyListeners();
  }

  String noOfPassengers = "1";
  void updateNoOfPassengers(String passengers) {
    noOfPassengers = passengers;
    notifyListeners();
  }

  String paymentType = "Cash";
  void updatePaymentType(String paymentTypes) {
    paymentType = paymentTypes;
    notifyListeners();
  }

  String stripeToken = "";
  void updatestripeToken(String token) {
    stripeToken = token;
    notifyListeners();
  }

  String rideTypeStatus = "";
  void updateRideTypeStatus(String status) {
    rideTypeStatus = status;
    notifyListeners();
  }

  String currentRideStatus;
  void updateCurrentRideStatus(String status) {
    currentRideStatus = status;
    notifyListeners();
  }

  String rideStatus;
  void updateRideStatus(String status) {
    rideStatus = status;
    notifyListeners();
  }

  String statusRide;
  void updateStatusRide(String status) {
    if (status == 'accepted') {
      currentRideStatus = status;
    }
    if (status == 'CANCELLED_BY_PASSENGER') {
      currentRideStatus = status;
    }
    if (status == 'SCHEDULE_TRIP') {
      currentRideStatus = status;
    }
    statusRide = status;
    notifyListeners();
  }

  String suggestedAmount;
  void updateSuggestedAmount(String amount) {
    suggestedAmount = amount;
    notifyListeners();
  }

  List<Driver> suggestedDrivers = [];
  void updateSuggestedDrivers(Driver driver) {
    suggestedDrivers.add(driver);
    notifyListeners();
  }

  void clearSuggestedDrivers() {
    suggestedDrivers.clear();
  }

  Driver selectedDriver;
  void setSelectedDriver(Driver driver) {
    selectedDriver = driver;
    notifyListeners();
  }

  void setPaymentMethod(String _paymentMethod) {
    paymentMethod = _paymentMethod;
    notifyListeners();
  }

  void setRideType(String _rideType) {
    rideType = _rideType;
    notifyListeners();
  }

  void setFareAmount(String _fareAmount) {
    fareAmount = _fareAmount;
    notifyListeners();
  }

  void clearSelectedDriver() {
    selectedDriver = null;
  }

  void initTimeout() {
    driverRequestTimeOut = 80;
  }

  String customerComment;
  void updateCustomerComment(String comment) {
    customerComment = comment;
    notifyListeners();
  }

  // //history
  // void updateEarnings(String updatedEarnings)
  // {
  //   earnings = updatedEarnings;
  //   notifyListeners();
  // }

  // void updateTripsCounter(int tripCounter)
  // {
  //   countTrips = tripCounter;
  //   notifyListeners();
  // }

  // void updateTripKeys(List<String> newKeys)
  // {
  //   tripHistoryKeys = newKeys;
  //   notifyListeners();
  // }

  // void updateTripHistoryData(History eachHistory)
  // {
  //   tripHistoryDataList.add(eachHistory);
  //   notifyListeners();
  // }
}
