import 'package:flutter/material.dart';

class Driver {
  String uid;
  String username;
  String imageurl;
  String? lat;
  String? long;
  String phone;
  String? timetoreach;
  String cabimage;
  String cab_model;
  String cab_number;
  String rating;
  String driver_token;
  Driver(
      {required this.cabimage,
      required this.uid,
      required this.username,
      required this.imageurl,
      required this.phone,
      required this.cab_model,
      required this.cab_number,
      required this.rating,
      required this.driver_token,
      this.timetoreach,
      this.lat,
      this.long});
}
