import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpHandler {
  static Future<dynamic> get(String url, String path, dynamic q,
      {dynamic headers = null}) async {
    var uri = Uri.https(url, path, q);

    http.Response response = await http.get(uri, headers: headers);

    try {
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var decodedData = jsonDecode(jsonData);
        return decodedData;
      } else {
        return 'Failed';
      }
    } catch (exp) {
      return 'Failed';
    }
  }

  static Future<dynamic> post(
      String url, String path, dynamic q, dynamic headers, dynamic body) async {
    var uri = Uri.https(url, path, q);

    http.Response response =
        await http.post(uri, headers: headers, body: jsonEncode(body));

    try {
      // print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 202) {
        String jsonData = response.body;
        var decodedData = jsonDecode(jsonData);
        return {'status': 'success', 'body': decodedData};
        ;
      } else {
        return {'status': 'failed', 'body': response.body};
      }
    } catch (exp) {
      return {'status': 'success', 'body': exp};
    }
  }
}
