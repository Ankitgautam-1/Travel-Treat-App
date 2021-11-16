import 'package:flutter/material.dart';

class DriverDetails {
  String username;
  String imageurl;
  double rating;
  String uid;
  DriverDetails(
      {required this.uid,
      required this.username,
      required this.imageurl,
      required this.rating});
}
