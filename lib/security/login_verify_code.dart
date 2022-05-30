import 'dart:async';

import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/main_screen.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/security/registration_after_phone.dart';
import 'package:cheetah_redux/utils/app_widget.dart';
import 'package:cheetah_redux/utils/colors.dart';
import 'package:cheetah_redux/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginCodeVerification extends StatefulWidget {
  static const String idScreen = "LoginCodeVerification";
  final String verificationId;
  final int forceResendingToken;

  const LoginCodeVerification(
      {Key key, this.verificationId, this.forceResendingToken})
      : super(key: key);

  @override
  LoginCodeVerificationState createState() => LoginCodeVerificationState();
}

class LoginCodeVerificationState extends State<LoginCodeVerification> {
  Timer _timer;
  int _start = 60;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // changeStatusColor(qIBus_colorPrimary);
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: app_background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            titleWidget("Code verification", context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Image.asset('images/pro_kit/qibus_ic_logo_splash.gif',
                        width: 75, height: 75, fit: BoxFit.fill),
                    SizedBox(
                      height: 40,
                    ),
                    text("Enter the code you just received",
                        isLongText: true, isCentered: true),
                    SizedBox(
                      height: 16,
                    ),
                    PinEntryTextField(
                      fields: 6,
                      fontSize: textSizeLargeMedium,
                      showFieldAsBox: true,
                      onSubmit: (String value) {
                        final code = value.trim();
                        validateAsync(code);
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _start == 0
                              ? Text("Send again",
                                  style: TextStyle(
                                      color: colorPrimary,
                                      fontSize: textSizeMedium))
                              : Text("$_start Seconds",
                                  style: TextStyle(
                                      color: colorPrimary,
                                      fontSize: textSizeMedium)),
                          Row(
                            children: <Widget>[
                              text(
                                "Vérifier",
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Validation in progress ... Please wait'),
                                    ),
                                  );
                                  // widget.key.currentState.showSnackBar(SnackBar(
                                  //     content: Text(
                                  //         "Veuillez vérifier votre téléphone pour le code de validation.")));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: colorPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: white,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future validateAsync(String code) async {
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: code);

    var result = await _auth.signInWithCredential(credential);

    firebaseUser = result.user;

    if (firebaseUser != null) {
      usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have been successfully registered'),
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterAfterPhoneScreen(
                phone: firebaseUser.phoneNumber,
              ),
            ),
          );
          Navigator.pushNamed(context, RegisterAfterPhoneScreen.idScreen);
        }
      });
    }
  }
}
