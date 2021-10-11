import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class AppProvider extends ChangeNotifier {
  late FirebaseApp app;

  Future<void> updateAppProvider(FirebaseApp app) async {
    this.app = app;
    notifyListeners();
  }
}
