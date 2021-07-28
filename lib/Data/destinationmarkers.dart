import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationMarkers extends ChangeNotifier {
  // ignore: avoid_init_to_null
  dynamic places = null;
  // ignore: avoid_init_to_null
  dynamic address = null;

  updateDestinationMarkers(LatLng? selectedPlace, String? address) {
    places = selectedPlace;
    this.address = address;
    notifyListeners();
  }
}
