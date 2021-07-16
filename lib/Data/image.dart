import 'dart:io';

import 'package:flutter/cupertino.dart';

class ImageData extends ChangeNotifier {
  File? image;

  void updateimage(File? profile) {
    image = profile;
    notifyListeners();
  }
}
