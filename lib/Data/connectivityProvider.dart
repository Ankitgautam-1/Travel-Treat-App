import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Connection extends ChangeNotifier {
  bool isConnected = false;
  late StreamSubscription streamsub;
  Connectivity _connectivity = Connectivity();
  getDataConnection() async {
    await getConnectivity();
    streamsub = _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        isConnected = false;
        notifyListeners();
      } else {
        isConnected = true;
        notifyListeners();
      }
    });
  }

  Future<void> getConnectivity() async {
    try {
      var state = await _connectivity.checkConnectivity();
      if (state == ConnectivityResult.none) {
        isConnected = false;
        notifyListeners();
      } else {
        isConnected = true;
        notifyListeners();
      }
    } on PlatformException catch (e) {
      print('Got Error while get data connnection details ${e.toString()}');
    }
  }

  @override
  void dispose() {
    streamsub.cancel();
    super.dispose();
  }
}
