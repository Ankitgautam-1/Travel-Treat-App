import 'dart:convert';
import 'dart:math';

import 'package:app/Data/userData.dart';
import 'package:app/models/userAddress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Geocoding {
  final String apikey = "58f6afdd9e6947d1b48437540521dca6";

  Future<dynamic> getAddress(Position position, context) async {
    final String baseurl = "https://api.opencagedata.com/geocode/v1/json?q=" +
        position.latitude.toString() +
        "+" +
        position.longitude.toString() +
        "&key=" +
        apikey;

    try {
      http.Response response = await http.get(Uri.parse(baseurl));
      if (response.statusCode == 200) {
        String jsonData = response.body;
        var decodeData = jsonDecode(jsonData);
        var address = decodeData["results"][0]["formatted"];
        var lat = decodeData["results"][0]["geometry"]["lat"];
        var lng = decodeData["results"][0]["geometry"]["lng"];
        print(" LatLng :$lat and $lng ");

        print('Your address is ->$address');

        UserAddress userAddress =
            new UserAddress(placeAddres: address, lat: lat, lng: lng);

        Provider.of<UserData>(context, listen: false)
            .updatepickuplocation(userAddress);
        return userAddress;
      } else if (response.statusCode == 400) {
        print(
            "Invalid request (bad request; a required parameter is missing; invalid coordinates; invalid version; invalid format)");
        return "Failed";
      } else if (response.statusCode == 404) {
        print("Invalid API endpoint");
        return "Failed";
      } else {
        print("Error $e");
        return "Failed";
      }
    } catch (e) {
      print("Error occured while connecting to the server $e");
      return "Failed";
    }
  }
}
