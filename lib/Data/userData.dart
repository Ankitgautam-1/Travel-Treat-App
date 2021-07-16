import 'package:app/models/userAddress.dart';
import 'package:flutter/cupertino.dart';

class UserData extends ChangeNotifier {
  UserAddress pickuplocation = UserAddress(placeAddres: "", lat: 0, lng: 0);
  void updatepickuplocation(UserAddress pickupAddress) {
    pickuplocation = pickupAddress;
    notifyListeners();
  }
}
