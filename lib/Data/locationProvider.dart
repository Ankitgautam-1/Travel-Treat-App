import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationProvider with ChangeNotifier {
  bool isServiceEnabled = false;
  getLocationServiceStatus() async {
    Location().onLocationChanged.listen((event) {
      
    });
  }
}
