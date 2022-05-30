import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stripe_payment/stripe_payment.dart';

class PaymentServices {
  static String _secretKey =
      'sk_test_51HQC8WLtqV8uAAoEUyqE3L7vAKK1ti9ofOg3qJfH1TtX2LiXmem037s4ShononaTeYqI4NSU9via0uxxrMoBYHg000v8TBUf8R';
  static String _publishableKey =
      'pk_test_51HQC8WLtqV8uAAoEC9igjszMh4mJT6n7hdy8w1hynYzPmekKBGPbyBmCQJz1j2wLfJTlDI9cQgiVd9mgdFpxAwwh00x1zHCe4O';

  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '$apiBase/payment_intents';

  static Map<String, String> headers = {
    'Authorization': 'Bearer ${_secretKey}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static PaymentMethod _paymentMethod;
  static PaymentIntentResult _paymentIntentResult;

  static initStripe() {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: _publishableKey,
        merchantId: "Test",
        // androidPayMode: 'test',
      ),
    );
  }

  static Future<Map<String, dynamic>> createCharge(String tokenId) async {
    print('createCharge $tokenId');
    var secret =
        'sk_test_51HQC8WLtqV8uAAoEUyqE3L7vAKK1ti9ofOg3qJfH1TtX2LiXmem037s4ShononaTeYqI4NSU9via0uxxrMoBYHg000v8TBUf8R';
    try {
      Map<String, dynamic> body = {
        'amount': '2000',
        'currency': 'usd',
        'source': "tok_1K3aJHAKGUvzJoV9G8ah9Sa0",
        'description': 'My first try'
      };
      print('createCharge ${body.values}');

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/charges'),
          body: body,
          headers: {
            'Authorization': 'Bearer $secret',
            'Content-Type': 'application/x-www-form-urlencoded'
          });

      print('createCharge ${response.reasonPhrase}');
      print('createCharge ${response.statusCode}');
      print('createCharge ${response.body}');
      print('createCharge ${response.contentLength}');

      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }

  // static Future<Map<String, dynamic>> createCharge(
  //     {String tokenId, String fareAmount}) async {
  //   final CreditCard creditCard = CreditCard(token: tokenId, currency: 'USD');

  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': '200',
  //       'currency': 'usd',
  //       'source': tokenId,
  //     };

  //     print("body $body");

  //     var response = await http.post(
  //         Uri.parse('https://api.stripe.com/v1/charges'),
  //         body: body,
  //         headers: {
  //           'Authorization': 'Bearer $_secretKey',
  //           'Content-Type': 'application/x-www-form-urlencoded'
  //         });

  //     print("Stripe: ${response.body}");
  //     return jsonDecode(response.body);
  //   } catch (err) {
  //     print('Stripe err charging user: ${err.toString()}');
  //   }
  //   return null;
  // }

  // static Future<Map<String, dynamic>> createPaymentIntent(
  //     String amount, String currency) async {
  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': amount,
  //       'currency': currency,
  //       'payment_method_types[]': 'card'
  //     };
  //     var uri = Uri.parse(paymentApiUrl);
  //     var response = await http.post(
  //       uri,
  //       body: body,
  //       headers: headers,
  //     );
  //     return jsonDecode(response.body);
  //   } catch (err) {
  //     print('err charging user: ${err.toString()}');
  //   }
  //   return null;
  // }

  // static getPaymentIntent() {
  //   StripePayment.confirmPaymentIntent(
  //     PaymentIntent(
  //       clientSecret: _secretKey,
  //       paymentMethodId: _paymentMethod.id,
  //     ),
  //   ).then((paymentIntentResult) {
  //     _paymentIntentResult = paymentIntentResult;
  //   });
  // }
}
