import 'dart:convert';
import 'package:app/Data/DirectionProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const String base_url = "https://trueway-directions2.p.rapidapi.com";

class Directions {
  String endpoint;
  String origin;
  String destination;
  BuildContext context;
  Directions(
      {required this.endpoint,
      required this.origin,
      required this.destination,
      required this.context});
  static const Map<String, String> _headers = {
    "x-rapidapi-key": "39742dd90emsh55eddbdd0f149d1p15562ajsn437a00f3158c",
    "x-rapidapi-host": "trueway-directions2.p.rapidapi.com"
  };
//URI - Uniform resource identifier
  Future<List<LatLng>?> getDirections() async {
    Uri url = Uri.parse(base_url +
        "/" +
        endpoint +
        "?origin=" +
        origin +
        "&destination=" +
        destination);

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
          List cordinates = res["route"]["geometry"]["coordinates"];
          print("cordinates:$cordinates");

          LatLngBounds bounds = LatLngBounds(
              southwest: LatLng(res["route"]["bounds"]["south"],
                  res["route"]["bounds"]["west"]),
              northeast: LatLng(res["route"]["bounds"]["north"],
                  res["route"]["bounds"]["east"]));
          List<LatLng> cordinates_collections = [];
          for (int i = 0; i < cordinates.length; i++) {
            for (int j = 0; j < cordinates[i].length; j = j + 2) {
              print("j=$j ");
              print("data: ${cordinates[i][j]}");
              cordinates_collections
                  .add(LatLng(cordinates[i][j], cordinates[i][j + 1]));
            }
          }
          print("new here:->cordinates_collections:$cordinates_collections");
          Provider.of<DirectionsProvider>(context, listen: false)
              .updateDirectionsProvider(cordinates_collections, bounds);

          return cordinates_collections;
        } catch (e) {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error is :$e");
      return null;
    }
  }
}
