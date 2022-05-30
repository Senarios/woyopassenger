import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/search_screen.dart';
import 'package:cheetah_redux/models/direction_details.dart';
import 'package:cheetah_redux/network/location_repository.dart';
import 'package:cheetah_redux/utils/divider.dart';
import 'package:cheetah_redux/utils/progress_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class SearchRide extends StatefulWidget {
  const SearchRide({Key key}) : super(key: key);

  @override
  _SearchRideState createState() => _SearchRideState();
}

class _SearchRideState extends State<SearchRide> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: AnimatedSize(
        vsync: this,
        curve: Curves.bounceIn,
        duration: new Duration(milliseconds: 160),
        child: Container(
          height: Provider.of<AppDataProvider>(context, listen: true)
              .searchContainerHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0)),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6.0),
                Text(
                  "Bonjour,",
                  style: TextStyle(fontSize: 12.0),
                ),
                Text(
                  "Where do you want to go?",
                  style: TextStyle(fontSize: 20.0, fontFamily: "Brand Bold"),
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () async {
                    var searchResult = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchScreen()));

                    if (searchResult == "obtainDirection") {
                      displayRideDetailsContainer();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 6.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text("Enter a destination ..."),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 300),
                          child: Container(
                            child: Text(
                              Provider.of<AppDataProvider>(context, listen: false)
                                          .pickUpLocation !=
                                      null
                                  ? Provider.of<AppDataProvider>(context, listen: false)
                                      .pickUpLocation
                                      .placeName
                                  : "Add home",
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          "Your Home",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                DividerWidget(),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(
                      Icons.work,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Add work"),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          "Your workplace",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    Provider.of<AppDataProvider>(context, listen: false)
        .updateSearchContainerHeight(0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateRideDetailsContainerHeight(340.0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateBottomPaddingOfMap(360.0);
    Provider.of<AppDataProvider>(context, listen: false)
        .updateDrawerOpen(false);
  }

  Future<void> getPlaceDirection() async {
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
    setState(() {
      tripDirectionDetails = details;
    });

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
    // setState(() {
    //   circlesSet.add(pickUpLocCircle);
    //   circlesSet.add(dropOffLocCircle);
    // });
  }
}
