import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/main_screen.dart';
import 'package:cheetah_redux/main.dart';
import 'package:cheetah_redux/utils/colors.dart';
import 'package:cheetah_redux/utils/progress_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class RegisterAfterPhoneScreen extends StatefulWidget {
  static const String idScreen = "registerAfterPhone";
  final String phone;

  const RegisterAfterPhoneScreen({Key key, this.phone}) : super(key: key);
  @override
  _RegisterAfterPhoneScreen createState() => _RegisterAfterPhoneScreen();
}

class _RegisterAfterPhoneScreen extends State<RegisterAfterPhoneScreen> {
  TextEditingController firstNameTextEditingController =
      TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 150.0,
              ),
              Image.asset('images/pro_kit/qibus_ic_logo_splash.gif',
                  width: 75, height: 75, fit: BoxFit.fill),
              Padding(
                padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      "Please provide your information",
                      style:
                          TextStyle(fontFamily: "Brand Bold", fontSize: 24.0),
                    ),
                    SizedBox(
                      height: 26.0,
                    ),
                    TextField(
                      controller: lastNameTextEditingController,
                      decoration: InputDecoration(
                        labelText: "First name",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: firstNameTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 10.0),
                      ),
                      style: TextStyle(fontSize: 15.0),
                    ),
                    SizedBox(
                      height: 42.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: RaisedButton(
                        onPressed: () {
                          if (firstNameTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "le nom est obligatoire.", context);
                          } else if (lastNameTextEditingController
                              .text.isEmpty) {
                            displayToastMessage(
                                "Le prénom est obligatoire.", context);
                          } else {
                            saveUserInfo(context);
                          }
                        },
                        color: Colors.orange,
                        child: Padding(
                          padding: EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "NEXT",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 26.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveUserInfo(context) async {
    var name =
        "${firstNameTextEditingController.text} ${lastNameTextEditingController.text}";

    usersRef.child(firebaseUser.uid).set({
      "name": name.trim(),
      "phone": firebaseUser.phoneNumber,
      "email": emailTextEditingController.text,
    });

    FirebaseFirestore.instance.collection("users").doc(firebaseUser.uid).set({
      "name": name.trim(),
      "phone": firebaseUser.phoneNumber,
      "email": emailTextEditingController.text,
      "id": firebaseUser.uid,
      "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
    });

    preferences = await SharedPreferences.getInstance();
    await preferences.setString("id", firebaseUser.uid);
    await preferences.setString("name", name.trim());
    if (!emailTextEditingController.text.isEmptyOrNull)
      await preferences.setString("email", emailTextEditingController.text);
    await preferences.setString("phone", firebaseUser.phoneNumber);

    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.idScreen, (route) => false);
  }
}
