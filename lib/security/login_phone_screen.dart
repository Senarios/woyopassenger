import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/main_screen.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/security/login_verify_code.dart';
import 'package:cheetah_redux/security/registration_after_phone.dart';
import 'package:cheetah_redux/security/registration_screen.dart';
import 'package:cheetah_redux/utils/colors.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPhoneScreen extends StatefulWidget {
  static const String idScreen = "login_phone";

  @override
  _LoginPhoneScreenState createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final _phoneController = TextEditingController();
  String countryCode;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

  @override
  void initState() {
    super.initState();
    setState(() {
      countryCode = "+225";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 200.0,
              ),
              Image.asset('images/pro_kit/qibus_ic_logo_splash.gif',
                  width: 75, height: 75, fit: BoxFit.fill),
              SizedBox(
                height: 1.0,
              ),
              Text(
                "Jomar Passager",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    Container(
                        padding: EdgeInsets.all(0),
                        child: Row(
                          children: <Widget>[
                            CountryCodePicker(
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
                    SizedBox(
                      height: 1.0,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      color: cheetah_yellow,
                      textColor: Colors.white,
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(24.0),
                      ),
                      onPressed: () {
                        if (_phoneController.text.isNotEmpty) {
                          final mobile =
                              this.countryCode + _phoneController.text.trim();
                          loginUser(mobile, context);
                        }
                      },
                    ),
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RegisterationScreen.idScreen, (route) => false);
                },
                child: Text(
                  "Vous n'avez pas de compte? Enregistrez vous ici",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCountryChange(CountryCode countryCode) {
    this.countryCode = countryCode.dialCode;
  }
}
