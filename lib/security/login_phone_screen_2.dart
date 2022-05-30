import 'package:animation_wrappers/Animations/faded_slide_animation.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/main_screen.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/security/registration_after_phone.dart';
import 'package:cheetah_redux/security/registration_screen.dart';
import 'package:cheetah_redux/utils/colors.dart';
import 'package:cheetah_redux/utils/custom_button.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'login_verify_code.dart';

class LoginPhoneUI extends StatefulWidget {
  static const String idScreen = "login_phone";

  LoginPhoneUI();

  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginPhoneUI> {
  final _phoneController = TextEditingController();
  String countryCode;

  String isoCode = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: FadedSlideAnimation(
        SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Spacer(flex: 5),
                Image.asset('images/pro_kit/qibus_ic_logo_splash.gif',
                    width: 75, height: 75, fit: BoxFit.fill),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text("Jomar Passager",
                      style: theme.textTheme.headline4.copyWith(fontSize: 35)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    "We'll send verification code to verify",
                    style: theme.textTheme.bodyText2
                        .copyWith(color: theme.hintColor, fontSize: 12),
                  ),
                ),
                Spacer(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  color: theme.backgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Spacer(),
                      Container(
                          padding: EdgeInsets.all(0),
                          child: Row(
                            children: <Widget>[
                              CountryCodePicker(
                                boxDecoration: BoxDecoration(
                                  color: Colors.black,
                                ),
                                onChanged: _onCountryChange,
                                padding: EdgeInsets.all(0),
                                initialSelection: 'CI',
                                favorite: ['+225', 'CI'],
                              ),
                              Container(
                                height: 30.0,
                                width: 1.0,
                                color: cheetah_yellow,
                                margin: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "Phone",
                                    labelStyle: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              )
                            ],
                          )),
                      Spacer(),
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context,
                              RegisterationScreen.idScreen, (route) => false);
                        },
                        child: Text(
                          "Vous n'avez pas de compte? Enregistrez vous ici",
                        ),
                      ),
                      Spacer(flex: 5),
                      CustomButton(
                        onTap: () {
                          if (_phoneController.text.isNotEmpty) {
                            final mobile =
                                this.countryCode + _phoneController.text.trim();
                            loginUser(mobile, context);
                          }
                        },
                        text: "Se connecter",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        beginOffset: Offset(0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    this.countryCode = countryCode.dialCode;
  }

  Future loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential credential) async {
        Navigator.of(context).pop();

        var result = await _auth.signInWithCredential(credential);

        firebaseUser = result.user;

        if (firebaseUser != null) {
          usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
            if (snap.value != null) {
              Navigator.pushNamedAndRemoveUntil(
                  context, MainScreen.idScreen, (route) => false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Phone number automatically verified : ${_auth.currentUser.phoneNumber}"),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterAfterPhoneScreen(
                    phone: firebaseUser.phoneNumber,
                  ),
                ),
              );
            }
          });
        }

        //This callback would gets called when verification is done auto maticlly
      },
      verificationFailed: (FirebaseAuthException exception) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.message),
          ),
        );
      },
      codeSent: (String verificationId, [int forceResendingToken]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Veuillez vérifier votre téléphone pour le code de validation.'),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginCodeVerification(
              verificationId: verificationId,
              forceResendingToken: forceResendingToken,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: null,
    );
  }
}
