import 'dart:convert';
import 'package:app/Data/DirectionProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const String base_url = "https://trueway-directions2.p.rapidapi.com";

class Msg {
  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Authorization":
        "key=AAAAPRPTcI4:APA91bGhPLuD0PnXQUUjJzD5UT6ZHygYMVGLflvrCduE_mwjitytNpYDa4Vr3vWENwcv4C_L8B6G9LvPO8HDImQ4ZpIXQ8E9bdYUuAPzY-JLSRfg109P7_nV4A1U6gJiPdwnro2V9u73"
  };
//URI - Uniform resource identifier
  Future<void> sendNotification(String token) async {
    Uri url = Uri.parse("https://fcm.googleapis.com/fcm/send");
    dynamic bodydata = jsonEncode(<String, dynamic>{
      "data": {
        "title": "New Text Message",
        "image": "https://firebase.google.com/images/social.png",
        "message": "Hello how are you?"
      },
      "to": token
    });
    print("Url = $url ");
    try {
      final response = await http.post(url, headers: _headers, body: bodydata);
      if (response.statusCode == 200) {
        try {
          // If server returns an OK response, parse the JSON.
          print("Json Data :----> ${response.body}");
          dynamic a = response.body.runtimeType;
          print("types :$a");
        } catch (e) {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error is :$e");
      return null;
    }
  }

  Future<void> sendRidereq(
    Position userLocation,
    String token,
    String uid,
    String username,
    String pickup,
    String destination,
    String usertoken,
    String travel_distance,
    String travel_time,
    String phone,
    String pickup_lat,
    String pickup_long,
    String destination_lat,
    String destination_long,
    String amount,
  ) async {
    Uri url = Uri.parse("https://fcm.googleapis.com/fcm/send");
    dynamic bodydata = jsonEncode(<String, dynamic>{
      "data": {
        "type": "Ride req",
        "title": "Passenger",
        "userData": {
          "pickuploc": {"lat": pickup_lat, "long": pickup_long},
          "destinationloc": {"lat": destination_lat, "long": destination_long},
          "user_uid": uid,
          "image":
              "https://ugxqtrototfqtawjhnol.supabase.in/storage/v1/object/public/travel-treat-storage/Users/$uid/$uid",
          "username": username,
          "pickup": pickup,
          "destination": destination,
          "usertoken": usertoken,
          "travel_distance": travel_distance,
          "travel_time": travel_time,
          "userlat": userLocation.latitude,
          "userlong": userLocation.longitude,
          "phone": phone,
          "amount": amount
        },
      },
      "to": token
    });
    print("Url = $bodydata ");
    try {
      final response = await http.post(url, headers: _headers, body: bodydata);
      if (response.statusCode == 200) {
        try {
          // If server returns an OK response, parse the JSON.
          print("Json Data :----> ${response.body}");
          dynamic a = response.body.runtimeType;
          print("types :$a");
        } catch (e) {
          print("Failed $e");
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error is :$e");
      return null;
    }
  }

  Future<void> sendRideCancelReq(
    String token,
  ) async {
    Uri url = Uri.parse("https://fcm.googleapis.com/fcm/send");
    dynamic bodydata = jsonEncode(<String, dynamic>{
      "data": {
        "type": "Ride cancel",
        "title": "Passenger",
      },
      "to": token
    });
    print("Url = $bodydata ");
    try {
      final response = await http.post(url, headers: _headers, body: bodydata);
      if (response.statusCode == 200) {
        try {
          // If server returns an OK response, parse the JSON.
          print("Json Data :----> ${response.body}");
          dynamic a = response.body.runtimeType;
          print("types :$a");
        } catch (e) {
          print("Failed $e");
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print("Error is :$e");
      return null;
    }
  }
}
