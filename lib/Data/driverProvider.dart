import 'package:app/models/driver.dart';
import 'package:flutter/cupertino.dart';

class DriverProvider extends ChangeNotifier {
  Driver driver = Driver(
      cabimage: "",
      uid: "",
      username: "",
      imageurl: "",
      phone: "",
      cab_model: "",
      cab_number: "",
      rating: "");

  void updateDriver(Driver driver) {
    this.driver = driver;
    notifyListeners();
  }
}
