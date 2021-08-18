import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsProvider extends ChangeNotifier {
  List<LatLng>? cordinates_collections = [];
  // ignore: avoid_init_to_null
  LatLngBounds? bounds = null;
  double? time;
  double? distance;

  updateDirectionsProvider(
      List<LatLng>? cordinates, LatLngBounds? bound, int? time, int? distance) {
    print("TIME-->$time and Distance $distance");
    cordinates_collections = cordinates;
    this.bounds = bound;
    this.time = time! / 60;
    this.distance = distance! / 1000;
    notifyListeners();
  }
}
