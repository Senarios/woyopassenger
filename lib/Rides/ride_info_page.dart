import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:cheetah_redux/Assets/assets.dart';
import 'package:cheetah_redux/Theme/style.dart';
import 'package:cheetah_redux/home/widgets/row_item.dart';
import 'package:cheetah_redux/models/history.dart';
import 'package:flutter/material.dart';

class RideInfoPage extends StatelessWidget {
  static const String idScreen = "rideInfoPage";

  final History history;

  const RideInfoPage({Key key, this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Stack(
      children: [
        // BackgroundImage(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(),
          body: FadedSlideAnimation(
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 100,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
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
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // history.,
                            '',
                            style: theme.textTheme.headline6
                                .copyWith(fontSize: 18, letterSpacing: 1.2),
                          ),
                          Spacer(flex: 2),
                          Text(
                            'Maruti Suzuki WagonR',
                            style:
                                theme.textTheme.caption.copyWith(fontSize: 12),
                          ),
                          Spacer(),
                          Text(
                            'DL 1 ZA 5887',
                            style: theme.textTheme.bodyText1
                                .copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      // Spacer(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: AppTheme.ratingsColor,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Text(
                                  //   '4.2',
                                  //   style: theme.textTheme.bodyText1
                                  //       .copyWith(fontSize: 12),
                                  // ),
                                  // SizedBox(width: 4),
                                  // Icon(
                                  //   Icons.star,
                                  //   color: AppTheme.starColor,
                                  //   size: 10,
                                  // )
                                ],
                              ),
                            ),
                            Spacer(flex: 2),
                            Text(
                              Strings.BOOKED_ON,
                              style: theme.textTheme.caption,
                            ),
                            Spacer(),
                            Text(
                              Strings.YESTERDAY + ', 10:25 pm',
                              style: theme.textTheme.bodyText1
                                  .copyWith(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      ListTile(
                        horizontalTitleGap: 0,
                        title: Text(
                          Strings.RIDE_INFO,
                          style: theme.textTheme.headline6
                              .copyWith(color: theme.hintColor, fontSize: 16.5),
                        ),
                        trailing: Text('08 km',
                            style: theme.textTheme.headline6
                                .copyWith(fontSize: 16.5)),
                      ),
                      ListTile(
                        horizontalTitleGap: 0,
                        leading: Icon(
                          Icons.location_on,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        title: Text(
                          '2nd ave, World Trade Center',
                          style: TextStyle(fontWeight: FontWeight.w500),
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
                          '1124, Golden Point Street',
                          style: TextStyle(fontWeight: FontWeight.w500),
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
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16))),
                  child: Row(
                    children: [
                      RowItem(Strings.PAYMENT_VIA, Strings.PAYMENT_MODE_CASH,
                          Icons.account_balance_wallet),
                      Spacer(),
                      RowItem(Strings.RIDE_FARE, '\$ 40.50',
                          Icons.account_balance_wallet),
                      Spacer(),
                      RowItem(
                          Strings.RIDE_TYPE, Strings.PRIVATE, Icons.drive_eta),
                    ],
                  ),
                ),
              ],
            ),
            beginOffset: Offset(0, 0.3),
            endOffset: Offset(0, 0),
            slideCurve: Curves.linearToEaseOut,
          ),
        ),
      ],
    );
  }
}
