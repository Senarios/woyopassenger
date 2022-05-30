import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/main_screen.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/security/registration_screen.dart';
import 'package:cheetah_redux/utils/colors.dart';
import 'package:cheetah_redux/utils/custom_button.dart';
import 'package:cheetah_redux/utils/entry_field.dart';
import 'package:cheetah_redux/utils/progress_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LoginScreenUI extends StatefulWidget {
  static const String idScreen = "login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenUI> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: FadedSlideAnimation(
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // AppBar(),
                        Image.asset('images/pro_kit/qibus_ic_logo_splash.gif',
                            width: 75, height: 75, fit: BoxFit.fill),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Login",
                            style: theme.textTheme.headline4,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Text(
                            "Enter required information",
                            style: theme.textTheme.bodyText2
                                .copyWith(color: theme.hintColor, fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: theme.backgroundColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                EntryField(
                                  controller: emailTextEditingController,
                                  label: "Courriel",
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                EntryField(
                                  controller: passwordTextEditingController,
                                  label: "Mot de passe",
                                  obscureText: true,
                                ),
                                Spacer(),
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, RegisterationScreen.idScreen, (route) => false);
                                  },
                                  child: Text(
                                    "No account? Register Here",
                                  ),
                                ),
                                Spacer(flex: 6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              start: 0,
              end: 0,
              child: CustomButton(
                text: "Login",
                onTap: () {
                  if (!emailTextEditingController.text.contains("@")) {
                    displayToastMessage(
                        "Email not valid.", context);
                  } else if (passwordTextEditingController.text.isEmpty) {
                    displayToastMessage(
                        "Password mandatory.", context);
                  } else {
                    loginAndAuthenticateUser(context);
                  }
                },
              ),
            ),
          ],
        ),
        beginOffset: Offset(0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Authenticating, please wait...",
          );
        });

    firebaseUser = (await _firebaseAuth
        .signInWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text)
        .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Erreur: " + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if (snap.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.idScreen, (route) => false);
          displayToastMessage("You are connected.", context);
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage(
              "Account does not exist, please create",
              context);
        }
      });
    } else {
      Navigator.pop(context);
      displayToastMessage(
          "An error has occurred, cannot be connected.", context);
    }
  }
}
