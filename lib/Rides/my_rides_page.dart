import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:cheetah_redux/Assets/assets.dart';
import 'package:cheetah_redux/Assistants/assistantMethods.dart';
import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class MyRidesPage extends StatefulWidget {
  static const String idScreen = "myRidesPage";

  @override
  State<MyRidesPage> createState() => _MyRidesPageState();
}

class _MyRidesPageState extends State<MyRidesPage> {
  @override
  void initState() {
    super.initState();
    AssistantMethods.retrieveHistoryInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var historyList = Provider.of<AppDataProvider>(context, listen: false)
        .historyTripDataList;
    // sortHistoryList(historyList);

    return Scaffold(
      appBar: AppBar(),
      body: FadedSlideAnimation(
        ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                Strings.MY_RIDES,
                style: theme.textTheme.headline4,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    Strings.LIST_OF_RIDES,
                    style: theme.textTheme.bodyText2
                        .copyWith(color: theme.hintColor, fontSize: 12),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    AssistantMethods.retrieveHistoryInfo(context);
                    Future.delayed(Duration(seconds: 1)).then((value) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => super.widget,
                          fullscreenDialog: true,
                        ),
                      );
                    });
                  },
                  icon: Icon(Icons.refresh),
                )
              ],
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              // reverse: true,
              itemCount: historyList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  print("RIDE ID: ${historyList[index].rideId}");
                  // Navigator.pushNamedAndRemoveUntil(context, RideInfoPage.idScreen, (route) => false);

                  // Navigator.pushNamed(context, PageRoutes.rideInfoPage),
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => RideInfoPage(
                  //       history: historyList[index],
                  //     ),
                  //   ),
                  // );
                },
                child: historyList[index].status != 'SCHEDULE_TRIP'
                    ? Column(
                        children: [
                          Container(
                            height: 80,
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            color: theme.backgroundColor,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(Assets.Driver),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AssistantMethods.formatTripDate(
                                          historyList[index].createdAt),
                                      //historyList[index].pickup,
                                      style: theme.textTheme.bodyText2,
                                    ),
                                    Spacer(flex: 2),
                                    Text(
                                      historyList[index].rideType == null
                                          ? ""
                                          : historyList[index].rideType,
                                      style: theme.textTheme.caption,
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$ ' +
                                          (historyList[index].fares == null ||
                                                  historyList[index].fares == ''
                                              ? "0"
                                              : historyList[index].fares),
                                      style: theme.textTheme.bodyText2
                                          .copyWith(color: theme.primaryColor),
                                    ),
                                    Spacer(flex: 2),
                                    Text(
                                      historyList[index].paymentMethod,
                                      textAlign: TextAlign.right,
                                      style: theme.textTheme.bodyText1,
                                    ),
                                    Spacer(flex: 2),
                                    Text(
                                      (historyList[index].status == null
                                          ? ""
                                          : historyList[index].status),
                                      textAlign: TextAlign.right,
                                      style: historyList[index].status ==
                                              'CANCELLED_BY_PASSENGER'
                                          ? TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[700],
                                            )
                                          : theme.textTheme.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            horizontalTitleGap: 0,
                            leading: Icon(
                              Icons.location_on,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                            title: Text(
                              historyList[index].pickup,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            dense: true,
                            tileColor: theme.cardColor,
                          ),
                          ListTile(
                            horizontalTitleGap: 0,
                            leading: Icon(
                              Icons.navigation,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                            title: Text(
                              historyList[index].dropOff,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            dense: true,
                            tileColor: theme.cardColor,
                          ),
                          SizedBox(height: 12),
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            height: 80,
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            color: theme.backgroundColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(Assets.Driver),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AssistantMethods.formatTripDate(
                                          historyList[index].createdAt),
                                      //historyList[index].pickup,
                                      style: theme.textTheme.bodyText2,
                                    ),
                                    Spacer(flex: 1),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          historyList[index].rideType == null
                                              ? ""
                                              : historyList[index].rideType,
                                          style: theme.textTheme.caption,
                                        ),
                                        SizedBox(width: 20),
                                        Text(
                                          (historyList[index].status == null
                                              ? ""
                                              : historyList[index].status),
                                          textAlign: TextAlign.right,
                                          style: theme.textTheme.caption,
                                        ),
                                      ],
                                    ),
                                    Spacer(flex: 1),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          historyList[index].paymentMethod,
                                          textAlign: TextAlign.right,
                                          style: theme.textTheme.bodyText1,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          ': \$ ' +
                                              (historyList[index].fares ==
                                                          null ||
                                                      historyList[index]
                                                              .fares ==
                                                          ''
                                                  ? "0"
                                                  : historyList[index].fares),
                                          style: theme.textTheme.bodyText2
                                              .copyWith(
                                                  color: theme.primaryColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Spacer(),
                                CustomButton(
                                  text: 'Cancel',
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    print(
                                        'CANCEL ${historyList[index].rideId}');
                                    cancelRide(historyList[index].rideId);
                                    Fluttertoast.showToast(
                                        msg: 'Your Ride has been Cancelled');
                                    Navigator.pop(context);
                                    // rideRequestRef
                                    //     .child(historyList[index].rideId)
                                    //     .child("status")
                                    //     .set("CANCELLED_BY_PASSENGER");
                                  },
                                )
                              ],
                            ),
                          ),
                          ListTile(
                            horizontalTitleGap: 0,
                            leading: Icon(
                              Icons.location_on,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                            title: Text(
                              historyList[index].pickup,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            dense: true,
                            tileColor: theme.cardColor,
                          ),
                          ListTile(
                            horizontalTitleGap: 0,
                            leading: Icon(
                              Icons.navigation,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                            title: Text(
                              historyList[index].dropOff,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            dense: true,
                            tileColor: theme.cardColor,
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
              ),
            )
          ],
        ),
        beginOffset: Offset(0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
      ),
    );
  }

  void cancelRide(String rideID) {
    print("CANCEL $rideID");
    rideRequestRef.child(rideID).child("status").set("CANCELLED_BY_PASSENGER");
    // print("CANCEL $rideID");
  }

  // void sortHistoryList(List<History> historyList) {
  //   // print("HISTORY BEFORE: ${historyList.toString()}");
  //   historyList.sort((a, b) {
  //     var aDate = DateTime.parse(a.createdAt);
  //     var bDate = DateTime.parse(b.createdAt);
  //     // print('DATE:  $aDate');
  //     // print('DATE:  $bDate');

  //     return aDate.compareTo(bDate);
  //   });
  //   // print("HISTORY AFTER: ${historyList.toString()}");
  // }
}
