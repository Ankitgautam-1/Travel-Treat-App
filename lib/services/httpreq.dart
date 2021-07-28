import 'dart:convert';
import 'package:http/http.dart' as http;

const String base_url = "https://trueway-places.p.rapidapi.com";

class Httpreq {
  String place;
  String endpoint;
  String query;
  Httpreq({required this.place, required this.endpoint, required this.query});
  static const Map<String, String> _headers = {
    "x-rapidapi-key": "39742dd90emsh55eddbdd0f149d1p15562ajsn437a00f3158c",
    "x-rapidapi-host": "trueway-places.p.rapidapi.com"
  };
//URI - Uniform resource identifier
  Future<dynamic> getPlace() async {
    Uri url = Uri.parse(base_url + "/" + endpoint + "?" + query + "=" + place);
    print("Url = $url ");
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        try {
          // If server returns an OK response, parse the JSON.

          print("Json Data :----> ${response.body}");
          dynamic a = response.body.runtimeType;
          print("types :$a");
          var res = jsonDecode(response.body);

          return res;
        } catch (e) {
          return "Failed";
        }
      } else {
        return "Failed";
      }
    } catch (e) {
      print("Error is :$e");
      return "Failed";
    }
  }
}
