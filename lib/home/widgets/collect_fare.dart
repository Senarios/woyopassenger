import 'package:animation_wrappers/Animations/faded_slide_animation.dart';
import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:cheetah_redux/Assets/assets.dart';
import 'package:cheetah_redux/data_provider/app_data_provider.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/models/address.dart';
import 'package:cheetah_redux/models/driver.dart';
import 'package:cheetah_redux/utils/custom_button.dart';
import 'package:cheetah_redux/utils/entry_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../main.dart';

class CollectFareDialog extends StatefulWidget {
  final String paymentMethod;
  final String receiverPhone;
  final int fareAmount;

  List<String> paiementModeList = ['CASH', 'MTN'];
  String selectedPaiementMode;

  CollectFareDialog({this.paymentMethod, this.fareAmount, this.receiverPhone});

  @override
  _CollectFareDialogState createState() => _CollectFareDialogState();
}

class _CollectFareDialogState extends State<CollectFareDialog> {
  TextEditingController addCommentController = TextEditingController();
  List<String> paiementModeList = ['CASH', 'MTN'];
  String selectedPaiementMode;

  // CollectFareDialog({this.paymentMethod, this.fareAmount, this.receiverPhone});

  @override
  Widget build(BuildContext context) {
    Driver selectedDriver =
        Provider.of<AppDataProvider>(context, listen: true).selectedDriver;
    Address pickUpLocation =
        Provider.of<AppDataProvider>(context, listen: false).pickUpLocation;
    Address dropOffLocation =
        Provider.of<AppDataProvider>(context, listen: false).dropOffLocation;

    var theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(20),
      // height: MediaQuery.of(context).size.height,
      child: Material(
        color: Theme.of(context).backgroundColor,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: FadedSlideAnimation(
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height + 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back),
                              color: Theme.of(context).primaryColor,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        Assets.Driver,
                                        height: 72,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      //'George Smith',
                                      selectedDriver == null
                                          ? ""
                                          : selectedDriver.name,
                                      style: theme.textTheme.headline6.copyWith(
                                          fontSize: 18, letterSpacing: 1.2),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      //'Maruti Suzuki WagonR',
                                      '',
                                      style: theme.textTheme.caption
                                          .copyWith(fontSize: 12),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      //'DL 1 ZA 5887',
                                      selectedDriver == null
                                          ? ""
                                          : selectedDriver.car_details,
                                      style: theme.textTheme.bodyText1
                                          .copyWith(fontSize: 13.5),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Strings.RIDE_FARE,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                              color:
                                                  Theme.of(context).hintColor,
                                              fontSize: 18),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\$ ${widget.fareAmount}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                    ),
                                    SizedBox(height: 24),
                                    Text(
                                      Strings.PAYMENT_VIA,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                              color:
                                                  Theme.of(context).hintColor,
                                              fontSize: 18),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet,
                                          color: theme.primaryColor,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(Strings.PAYMENT_MODE_CASH)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        ListTile(
                          title: Text(
                            Strings.RIDE_INFO,
                            style: theme.textTheme.headline6.copyWith(
                                color: theme.hintColor, fontSize: 16.5),
                          ),
                          trailing:
                              Text('08 km', style: theme.textTheme.headline6),
                        ),
                        ListTile(
                          horizontalTitleGap: 0,
                          leading: Icon(
                            Icons.location_on,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          title: Text(
                            //'2nd ave, World Trade Center',
                            pickUpLocation == null
                                ? ""
                                : pickUpLocation.placeName,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
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
                            //'1124, Golden Point Street',
                            dropOffLocation == null
                                ? ""
                                : dropOffLocation.placeName,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Spacer(),
                        Divider(),
                        Spacer(),
                        Center(
                          child: Text(Strings.RATE_YOUR_RIDE,
                              style: theme.textTheme.headline6
                                  .copyWith(color: theme.hintColor)),
                        ),
                        Spacer(),
                        /*  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                              (index) => Icon(
                            Icons.star,
                            color: theme.primaryColor,
                            size: 40,
                          ),
                        ),
                      ),
                      Spacer(),*/

                        Center(
                            child: SmoothStarRating(
                          rating: starCounter,
                          color: theme.primaryColor,
                          allowHalfRating: false,
                          starCount: 5,
                          size: 45,
                          onRated: (value) {
                            starCounter = value;

                            if (starCounter == 1) {
                              setState(() {
                                title = "Very Bad";
                              });
                            }
                            if (starCounter == 2) {
                              setState(() {
                                title = "Bad";
                              });
                            }
                            if (starCounter == 3) {
                              setState(() {
                                title = "Good";
                              });
                            }
                            if (starCounter == 4) {
                              setState(() {
                                title = "Very Good";
                              });
                            }
                            if (starCounter == 5) {
                              setState(() {
                                title = "Excellent";
                              });
                            }
                          },
                        )),
                        Center(
                            child: Text(
                          title,
                          style: TextStyle(
                              fontSize: 25.0,
                              fontFamily: "Signatra",
                              color: Colors.white),
                        )),
                        Spacer(),
                        EntryField(
                          hint: Strings.ADD_COMMENT,
                          controller: addCommentController,
                        ),
                        SizedBox(
                          height: 60,
                        ),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  child: CustomButton(
                    onTap: () {
                      // Navigator.pop(context);
                      rideRequestRef
                          .child("passenger_feedback")
                          .child("comment")
                          .set(addCommentController.text.toString());
                      rideRequestRef
                          .child("passenger_feedback")
                          .child("rating")
                          .set(starCounter.toString());
                      // Provider.of<AppDataProvider>(context).updateCustomerComment(addCommentController.text);
                      Navigator.pop(context, "close");
                    },
                    text: Strings.SUBMIT,
                  ),
                ),
              ],
            ),
            beginOffset: Offset(0, 0.3),
            endOffset: Offset(0, 0),
            slideCurve: Curves.linearToEaseOut,
          ),
        ),
      ),
    );
  }
}
