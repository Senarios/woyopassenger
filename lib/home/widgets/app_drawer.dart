import 'package:animation_wrappers/Animations/faded_slide_animation.dart';
import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:cheetah_redux/Assets/assets.dart';
import 'package:cheetah_redux/Assistants/assistantMethods.dart';
import 'package:cheetah_redux/Rides/my_rides_page.dart';
import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/Theme/style.dart';
import 'package:cheetah_redux/models/address.dart';
import 'package:cheetah_redux/security/login_phone_screen.dart';
import 'package:cheetah_redux/security/login_screen.dart';
import 'package:cheetah_redux/utils/divider.dart';
import 'package:cheetah_redux/utils/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class AppDrawer extends StatefulWidget {
  //final String userName;
  // final String phoneNumber;

  //final bool fromHome;

  // const AppDrawer({Key key, this.userName, this.phoneNumber}) : super(key: key);

  AppDrawer();
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    // Provider.of<AppDataProvider>(context, listen: false)
    var provider = Provider.of<AppDataProvider>(context, listen: false);
    var theme = Theme.of(context);
    return Builder(builder: (BuildContext context) {
      return Drawer(
        child: FadedSlideAnimation(
          ListView(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                color: theme.scaffoldBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(Icons.close),
                        color: theme.primaryColor,
                        iconSize: 28,
                        onPressed: () => Navigator.pop(context)),
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              Assets.User,
                              height: 72,
                              width: 72,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 2.7,
                                child: Text(
                                    userCurrentInfo == null
                                        ? ""
                                        : userCurrentInfo?.name,
                                    style: theme.textTheme.headline5.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                              ),
                              SizedBox(height: 6),
                              Text(
                                  userCurrentInfo == null
                                      ? ""
                                      : userCurrentInfo?.phone,
                                  style: theme.textTheme.caption
                                      .copyWith(fontSize: 12)),
                              SizedBox(height: 4),
                              /*  Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: AppTheme.ratingsColor,
                              ),
                              child: Row(
                                children: [
                                  Text('4.2', style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.star,
                                    color: AppTheme.starColor,
                                    size: 10,
                                  )
                                ],
                              ),
                            ),*/
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 12,
              ),
              buildListTile(context, Icons.home, Strings.HOME, () {
                //  if (fromHome)
                //    Navigator.pop(context);
                //  else
                //   Navigator.pushReplacementNamed(
                //       context, PageRoutes.searchLocationPage);
                Navigator.pop(context);
              }),
              buildListTile(context, Icons.history, Strings.HISTORY, () {
                // Navigator.popAndPushNamed(context, PageRoutes.profilePage);
                //Navigator.pushNamedAndRemoveUntil(context, MyRidesPage.idScreen, (route) => false);
                AssistantMethods.retrieveHistoryInfo(context);
                Future.delayed(Duration(seconds: 1)).then((value) {
                  Navigator.popAndPushNamed(context, MyRidesPage.idScreen);
                });
              }),
              buildListTile(
                  context, Icons.trip_origin, Strings.ONE_CLICK_PICKUP, () {
                // Navigator.popAndPushNamed(context, PageRoutes.myRidesPage);

                String earn = provider?.earnings ?? "";
                print("earn ${earn}");

                var firebaseReference =
                    usersRef.child(firebaseUser.uid).child("one_click_pickup");
                firebaseReference.once().then((DataSnapshot datasnapshot) {
                  print("datasnapshot = ${datasnapshot.value}");
                  if (datasnapshot.value == null) {
                    print("Its null");
                    displayToastMessage(
                        "No favorite address found ...", context);
                  } else {
                    var adddressData = datasnapshot.value;
                    //   print("values[placeName] -- ${datasnapshot.value["placeName"]}");

                    Address address = Address();
                    address.placeName = datasnapshot.value["placeName"];
                    address.placeId = datasnapshot.value["placeId"];
                    address.latitude = datasnapshot.value["latitude"];
                    address.longitude = datasnapshot.value["longitude"];

                    // print( address.placeId);
                    // print( address.placeName);
                    // print( address.latitude);
                    // print( address.longitude);

                    print(
                        "Provider.of<AppDataProvider>(context, listen: false).earnings =${provider?.earnings ?? ""}=");
                    provider?.updateRideTypeStatus("ONE_CLICK_RIDE");
                    provider?.updateCurrentRideStatus("LOCATION_SELECTED");
                    provider?.updateDropOffLocationAddress(address);
                    //  print("provider?.updateDropOffLocationAddress ${provider?.dropOffLocation.placeName}");
                  }
                });

                Navigator.pop(context);

                //  onOneClickRide(context);
                // Navigator.pop(context);
              }),
              buildListTile(context, Icons.message, Strings.MESSAGES, () {
                // Navigator.popAndPushNamed(context, PageRoutes.myRidesPage);
              }),
              buildListTile(context, Icons.person, Strings.VISIT_PROFILE, () {
                // Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => ProfileTabPage())
                //             );
                /*  if (fromHome)
                    Navigator.popAndPushNamed(context, PageRoutes.walletPage);
                  else
                    Navigator.pushReplacementNamed(context, PageRoutes.walletPage);*/
              }),
              buildListTile(context, Icons.local_offer, Strings.ABOUT, () {
                /*   if (fromHome)
                Navigator.popAndPushNamed(context, PageRoutes.promoCodePage);
              else
                Navigator.pushReplacementNamed(
                    context, PageRoutes.promoCodePage); */
              }),
              buildListTile(context, Icons.logout, Strings.DISCONNECT, () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginPhoneScreen.idScreen, (route) => false);
                /* if (fromHome)
                Navigator.popAndPushNamed(context, PageRoutes.settingsPage);
              else
                Navigator.pushReplacementNamed(
                    context, PageRoutes.settingsPage);*/
              }),
            ],
          ),
          beginOffset: Offset(0, 0.3),
          endOffset: Offset(0, 0),
          slideCurve: Curves.linearToEaseOut,
        ),
      );
    });
  }

  ListTile buildListTile(BuildContext context, IconData icon, String title,
      [Function onTap]) {
    var theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor, size: 24),
      title: Text(
        title,
        style: theme.textTheme.headline5
            .copyWith(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      onTap: onTap as void Function(),
    );
  }

  void onOneClickRide(BuildContext context) {
    // Geofire.removeLocation(currentfirebaseUser.uid);
    var firebaseReference =
        usersRef.child(firebaseUser.uid).child("one_click_pickup");
    firebaseReference.once().then((DataSnapshot datasnapshot) {
      print("datasnapshot = ${datasnapshot.value}");
      if (datasnapshot.value == null) {
        print("Its null");
      } else {
        var adddressData = datasnapshot.value;
        print("values[placeName] -- ${datasnapshot.value["placeName"]}");

        Address address = Address();
        address.placeName = datasnapshot.value["placeName"];
        address.placeId = datasnapshot.value["placeId"];
        address.latitude = datasnapshot.value["latitude"];
        address.longitude = datasnapshot.value["longitude"];

        print(address.placeId);
        print(address.placeName);
        print(address.latitude);
        print(address.longitude);

        // print( "Provider.of<AppDataProvider>(context, listen: false).earnings =${Provider.of<AppDataProvider>(context, listen: false)?.earnings ?? ""}=");

        Provider.of<AppDataProvider>(context, listen: false)
            .updateDropOffLocationAddress(address);
      }
    });

    Navigator.pop(context);
  }
}

/*

import 'package:cheetah_redux/security/login_phone_screen.dart';
import 'package:cheetah_redux/security/login_screen.dart';
import 'package:cheetah_redux/utils/divider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String userName;

  const AppDrawer({Key key, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 255.0,
      child: Drawer(
        child: ListView(
          children: [
            //Drawer Header
            Container(
              height: 165.0,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Image.asset(
                      "images/user_icon.png",
                      height: 65.0,
                      width: 65.0,
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userName == null ? "" : userName,
                          style: TextStyle(
                              fontSize: 16.0, fontFamily: "Brand Bold"),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        GestureDetector(
                            // profile
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ProfileTabPage())
                              //         );
                            },
                            child: Text("Visit Profile")),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            DividerWidget(),

            SizedBox(
              height: 12.0,
            ),

            //Drawer Body Contrllers
            GestureDetector(
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => HistoryScreen()));
              },
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => ChatPage(
                //             currentUserId:
                //                 FirebaseAuth.instance.currentUser.uid)));
              },
              child: ListTile(
                leading: Icon(Icons.message),
                title: Text(
                  "Messages",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => ProfileTabPage()));
              },
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => AboutScreen()));
              },
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginPhoneScreen.idScreen, (route) => false);
              },
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  "Se déconnecter",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/