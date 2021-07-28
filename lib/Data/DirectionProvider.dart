import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsProvider extends ChangeNotifier {
  List<LatLng>? cordinates_collections = [];
  // ignore: avoid_init_to_null
  LatLngBounds? bounds = null;

  updateDirectionsProvider(List<LatLng>? cordinates, LatLngBounds? bound) {
    cordinates_collections = cordinates;
    this.bounds = bound;
    notifyListeners();
  }
}
