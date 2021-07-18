import 'package:app/models/userAddress.dart';
import 'package:flutter/cupertino.dart';

class UserData extends ChangeNotifier {
  // ignore: avoid_init_to_null
  UserAddress? pickuplocation = null;
  void updatepickuplocation(UserAddress? pickupAddress) {
    pickuplocation = pickupAddress;
    notifyListeners();
  }
}
