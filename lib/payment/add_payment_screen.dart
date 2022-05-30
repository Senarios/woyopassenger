import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:cheetah_redux/Assets/Strings.dart';
import 'package:cheetah_redux/Assistants/assistantMethods.dart';
import 'package:cheetah_redux/data_provider/global.dart';
import 'package:cheetah_redux/home/main_screen.dart';
import 'package:cheetah_redux/utils/custom_button.dart';
import 'package:cheetah_redux/utils/entry_field.dart';
import 'package:cheetah_redux/utils/progress_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stripe_payment/stripe_payment.dart';

class AddMoneyUI extends StatefulWidget {
  static const String idScreen = "addMoney_Ui";
  // final AddMoneyInteractor addMoneyInteractor;

  // AddMoneyUI(this.addMoneyInteractor);

  @override
  _AddMoneyUIState createState() => _AddMoneyUIState();
}

class _AddMoneyUIState extends State<AddMoneyUI> {
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();
  var expiryDate;
  // TextEditingController _amountController =
  //     TextEditingController(text: '\$ 500.00');

  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _currentUser = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: "pk_test_aSaULNS8cJU6Tvo20VAXy6rp",
        merchantId: "Test",
        androidPayMode: 'test',
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    // _amountController.dispose();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppBar(),
                    SizedBox(
                      height: 12,
                    ),
                    // Padding(
                    //   padding: EdgeInsets.symmetric(horizontal: 24),
                    //   child: Image.asset(
                    //     Assets.QMoneyIcon,
                    //     height: 72,
                    //     alignment: AlignmentDirectional.centerStart,
                    //   ),
                    // ),
                    SizedBox(
                      height: 48,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        Strings.ADD_WALLET,
                        style: theme.textTheme.headline4.copyWith(fontSize: 35),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        Strings.PAYMENT_MADE_EASY,
                        style: theme.textTheme.bodyText2
                            .copyWith(color: theme.hintColor, fontSize: 12),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Expanded(
                      child: Container(
                        // height: MediaQuery.of(context).size.height * 0.7,
                        color: theme.backgroundColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            EntryField(
                              controller: _cardNumberController,
                              label: Strings.CARD_NUMBER,
                              maxLength: 16,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: EntryField(
                                    controller: _expiryController,
                                    label: Strings.EXPIRY_DATE,
                                    onChanged: (value) {
                                      setState(() {
                                        value =
                                            value.replaceAll(RegExp(r"\D"), "");
                                        switch (value.length) {
                                          case 0:
                                            _expiryController.text = "MM/YY";
                                            _expiryController.selection =
                                                TextSelection.collapsed(
                                                    offset: 0);
                                            break;
                                          case 1:
                                            _expiryController.text =
                                                "${value}M/YY";
                                            _expiryController.selection =
                                                TextSelection.collapsed(
                                                    offset: 1);
                                            break;
                                          case 2:
                                            _expiryController.text =
                                                "$value/YY";
                                            _expiryController.selection =
                                                TextSelection.collapsed(
                                                    offset: 2);
                                            break;
                                          case 3:
                                            _expiryController.text =
                                                "${value.substring(0, 2)}/${value.substring(2)}Y";
                                            _expiryController.selection =
                                                TextSelection.collapsed(
                                                    offset: 4);
                                            break;
                                          case 4:
                                            _expiryController.text =
                                                "${value.substring(0, 2)}/${value.substring(2, 4)}";
                                            _expiryController.selection =
                                                TextSelection.collapsed(
                                                    offset: 5);
                                            break;
                                        }
                                        if (value.length > 4) {
                                          _expiryController.text =
                                              "${value.substring(0, 2)}/${value.substring(2, 4)}";
                                          _expiryController.selection =
                                              TextSelection.collapsed(
                                                  offset: 5);
                                        }
                                      });
                                    },
                                    // onChanged: (value) {
                                    //   if (value.length == 2)
                                    //     _expiryController.text +=
                                    //         "/"; //<-- Automatically show a '/' after dd
                                    //   expiryDate = value;
                                    // },
                                    // maxLength: 5,
                                  ),
                                ),
                                Expanded(
                                  child: EntryField(
                                    controller: _cvvController,
                                    label: Strings.CVV_CODE,
                                    maxLength: 3,
                                  ),
                                ),
                              ],
                            ),
                            // EntryField(
                            //   controller: _amountController,
                            //   label: Strings.ENTER_AMOUNT,
                            // ),
                            Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: Strings.SKIP,
                    onTap: () => skip(context),
                    color: theme.scaffoldBackgroundColor,
                    textColor: theme.primaryColor,
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    text: Strings.ADD_MONEY,
                    onTap: () {
                      if (_cardNumberController.text.isEmpty) {
                        displayToastMessage(
                            "Numéro de carte requise.", context);
                      } else if (_expiryController.text.isEmpty) {
                        displayToastMessage(
                            "Date d'expiration requise.", context);
                      } else if (_cvvController.text.isEmpty) {
                        displayToastMessage("Code CVV requise.", context);
                      } else if (_cardNumberController.text.length < 16) {
                        displayToastMessage(
                          "La longueur du numéro de carte doit être de 16 chiffres.",
                          context,
                        );
                      } else if (_cvvController.text.length < 3) {
                        displayToastMessage(
                          "Date incorrecte.",
                          context,
                        );
                      } else if (_expiryController.text.length < 4) {
                        // print(dateCheck);
                      } else {
                        _expiryDateChecker();

                        addCard(
                          cardNumber: _cardNumberController.text,
                          expiry: _expiryController.text,
                          cvv: _cvvController.text,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        beginOffset: Offset(0, 0.3),
        endOffset: Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
      ),
    );
  }

  _expiryDateChecker() {
    var dateCheck = _expiryController.text.split('/');
    var year = DateTime.now().year;
    var currentYear = year.toString().substring(2);
    // print("currentyear $year");
    print("currentyear $currentYear");

    // var currentYear = int.parse(DateTime.now().year.toString());
    if (int.parse(dateCheck[0]) > 12) {
      displayToastMessage(
        'Veuillez vérifier votre mois d\'expiration',
        context,
      );
    } else if (int.parse(dateCheck[1]) < (int.parse(currentYear))) {
      displayToastMessage(
        'Veuillez vérifier votre année d\'expiration.',
        context,
      );
    } else if (int.parse(dateCheck[1]) > (int.parse(currentYear) + 5)) {
      displayToastMessage(
        'Veuillez vérifier votre année d\'expiration.',
        context,
      );
    }
  }

  void addCard({String cardNumber, String expiry, String cvv}) {
    var expiryDate = expiry.split('/');
    print(cardNumber);
    print(expiry);
    print(expiryDate[0]);
    print(expiryDate[1]);
    print(cvv);
    print('ADD MONEY');

    final CreditCard creditCard = CreditCard(
      number: cardNumber,
      expMonth: int.parse(expiryDate[0]),
      expYear: int.parse(expiryDate[1]),
      cvc: cvv,
    );

    print(creditCard.toJson());

    StripePayment.createTokenWithCard(creditCard).then((token) {
      print(token.tokenId);
      _firebaseFirestore
          .collection('users')
          .doc(_currentUser.currentUser.uid)
          .update({
        "Token": token.tokenId,
      }).then((value) {
        Navigator.pushNamedAndRemoveUntil(
            context, MainScreen.idScreen, (route) => false);
      });

      // createCharge(token.tokenId);
    });

    // StripePayment.createTokenWithCard(
    //   creditCard,
    // ).then((token) {
    //   print("Token ${token.toJson()}");
    //   print("Token ${_currentUser.currentUser.uid}");

    //   _firebaseFirestore
    //       .collection('users')
    //       .doc(_currentUser.currentUser.uid)
    //       .update({
    //     "Token": token.tokenId,
    //   }).then((value) {
    //     Navigator.pushNamedAndRemoveUntil(
    //         context, MainScreen.idScreen, (route) => false);
    //   });
    // }).catchError(setError);
  }

  void setError(dynamic error) {
    displayToastMessage(
      error.toString(),
      context,
    );
  }

  void skip(context) {
    print('Skip');
    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.idScreen, (route) => false);
  }
}
