import 'package:cheetah_redux/home/main_screen.dart';
import 'package:cheetah_redux/main.dart';
import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cheetah_redux/payment/add_payment_screen.dart';
import 'package:cheetah_redux/utils/custom_button.dart';
import 'package:cheetah_redux/utils/entry_field.dart';
import 'package:cheetah_redux/utils/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';

class RegistrationUI extends StatefulWidget {
  static const String idScreen = "register";

  @override
  _RegistrationUIState createState() => _RegistrationUIState();
}

class _RegistrationUIState extends State<RegistrationUI> {
  static const String idScreen = "register";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  SharedPreferences preferences;

  @override
  void dispose() {
    nameTextEditingController.dispose();
    emailTextEditingController.dispose();
    phoneTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

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
                            "Sign Up",
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
                                  label: "Name",
                                  controller: nameTextEditingController,
                                  keyboardType: TextInputType.text,
                                ),
                                EntryField(
                                  controller: emailTextEditingController,
                                  label: "Email",
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                EntryField(
                                  controller: phoneTextEditingController,
                                  label: "Telephone",
                                  keyboardType: TextInputType.phone,
                                ),
                                EntryField(
                                  controller: passwordTextEditingController,
                                  label: "Password",
                                  obscureText: true,
                                ),
                                Spacer(),
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        LoginScreen.idScreen, (route) => false);
                                  },
                                  child: Text(
                                    "Already have an account? Log in here",
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
                text: "Create an account",
                onTap: () {
                  if (nameTextEditingController.text.length < 3) {
                    displayToastMessage(
                        "Le nom doit comporter au moins 3 caractères.",
                        context);
                  } else if (!emailTextEditingController.text.contains("@")) {
                    displayToastMessage(
                        "L'adresse email n'est pas valide.", context);
                  } else if (phoneTextEditingController.text.isEmpty) {
                    displayToastMessage(
                        "Le numéro de téléphone est obligatoire.", context);
                  } else if (passwordTextEditingController.text.length < 6) {
                    displayToastMessage(
                        "Le mot de passe doit être au moins de 6 caractères.",
                        context);
                  } else {
                    registerNewUser(context);
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

  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: "Registration, please wait ...",
          );
        });

    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: emailTextEditingController.text,
                password: passwordTextEditingController.text)
            .catchError((errMsg) {
      Navigator.pop(context);
      displayToastMessage("Erreur: " + errMsg.toString(), context);
    }))
        .user;

    if (firebaseUser != null) //user created
    {
      //save user info to database
      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      usersRef.child(firebaseUser.uid).set(userDataMap);

      // save to firestore
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection("users")
          .where("id", isEqualTo: firebaseUser.uid)
          .get();

      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;
      if (documentSnapshots.length == 0) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUser.uid)
            .set({
          "name": nameTextEditingController.text.trim(),
          "phone": phoneTextEditingController.text.trim(),
          "email": firebaseUser.email.trim(),
          "id": firebaseUser.uid,
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith": null,
        });

        preferences = await SharedPreferences.getInstance();
        await preferences.setString("id", firebaseUser.uid);
        await preferences.setString(
            "name", nameTextEditingController.text.trim());
        await preferences.setString("email", firebaseUser.email);
        await preferences.setString(
            "phone", phoneTextEditingController.text.trim());
      }

      displayToastMessage(
          "Congratulations, your account has been created.", context);

      Navigator.pushNamedAndRemoveUntil(
          context, AddMoneyUI.idScreen, (route) => false);
      // Navigator.pushNamedAndRemoveUntil(
      //     context, MainScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      //error occured - display error msg
      displayToastMessage(
          "Le nouveau compte utilisateur n'a pas été créé.", context);
    }
  }
}
