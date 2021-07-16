import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationMarkers extends ChangeNotifier {
  late dynamic places = [];

  updateDestinationMarkers(LatLng selectedPlace) {
    places = selectedPlace;
    notifyListeners();
  }
}
