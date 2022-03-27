import 'package:flutter/cupertino.dart';

class RatingProvider extends ChangeNotifier {
  double rating = 4.2;
  void setRating(double rating) {
    this.rating = rating;
    notifyListeners();
  }
}
