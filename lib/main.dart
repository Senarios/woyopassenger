import 'package:cheetah_redux/Theme/style.dart';
import 'package:cheetah_redux/home/main_screen.dart';
import 'package:cheetah_redux/payment/add_payment_screen.dart';
import 'package:cheetah_redux/security/login_phone_screen.dart';
import 'package:cheetah_redux/security/login_phone_screen_2.dart';
import 'package:cheetah_redux/security/login_screen.dart';
import 'package:cheetah_redux/security/login_screen_2.dart';
import 'package:cheetah_redux/security/login_verify_code.dart';
import 'package:cheetah_redux/security/registration_after_phone.dart';
import 'package:cheetah_redux/security/registration_screen.dart';
import 'package:cheetah_redux/security/registration_screen_2.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Rides/my_rides_page.dart';
import 'Rides/ride_info_page.dart';
import 'data_provider/app_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RiderApp());
}

DatabaseReference usersRef =
    FirebaseDatabase.instance.reference().child("users");
DatabaseReference driversRef =
    FirebaseDatabase.instance.reference().child("drivers");
DatabaseReference rideRequestRef =
    FirebaseDatabase.instance.reference().child("Ride Requests");

class RiderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppDataProvider(),
      child: MaterialApp(
        supportedLocales: [
          Locale("fr"),
          Locale("en"),
        ],
        localizationsDelegates: [CountryLocalizations.delegate],
        title: 'Taxi Rider App',
        theme: AppTheme.darkTheme,
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginPhoneUI.idScreen
            : MainScreen.idScreen,
        routes: {
          // RegisterationScreen.idScreen: (context) => RegisterationScreen(),
          RegistrationUI.idScreen: (context) => RegistrationUI(),
          RegisterAfterPhoneScreen.idScreen: (context) =>
              RegisterAfterPhoneScreen(),
          LoginCodeVerification.idScreen: (context) => LoginCodeVerification(),
          //LoginPhoneScreen.idScreen: (context) => LoginPhoneScreen(),
          LoginPhoneUI.idScreen: (context) => LoginPhoneUI(),
          //  LoginScreen.idScreen: (context) => LoginScreen(),
          LoginScreenUI.idScreen: (context) => LoginScreenUI(),
          MainScreen.idScreen: (context) => MainScreen(),
          MyRidesPage.idScreen: (context) => MyRidesPage(),
          RideInfoPage.idScreen: (context) => RideInfoPage(),
          AddMoneyUI.idScreen: (context) => AddMoneyUI(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
