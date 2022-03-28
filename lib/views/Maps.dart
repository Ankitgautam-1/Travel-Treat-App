import 'dart:async';

import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animations/animations.dart';
import 'package:app/Data/DirectionProvider.dart';
import 'package:app/Data/connectivityProvider.dart';
import 'package:app/Data/driverProvider.dart';

import 'package:app/Data/pickuploc.dart';
import 'package:app/Data/ratingProvider.dart';
import 'package:app/Utils/Utils.dart';
import 'package:app/models/driver.dart';
import 'package:app/models/driverDetails.dart';
import 'package:app/services/getDirections.dart';
import 'package:app/services/sending_notification.dart';
import 'package:app/views/accounts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:app/Data/accountProvider.dart';
import 'package:app/Data/destinationmarkers.dart';
import 'package:app/Data/image.dart';
import 'package:app/Data/userData.dart';
import 'package:app/models/userAccount.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:app/services/assistantmethod.dart';
import 'package:app/views/Welcome.dart';
import 'package:app/views/searchplace.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart' as loc;
import 'package:map_picker/map_picker.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:url_launcher/url_launcher.dart';

class Maps extends StatefulWidget {
  final FirebaseApp app;
  Maps({required this.app});
  @override
  _MapsState createState() => _MapsState(app: app);
}

class _MapsState extends State<Maps> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  FirebaseApp app;
  final geo = Geoflutterfire();
  late Stream<List<DocumentSnapshot>> locationStream;
  late StreamSubscription<List<DocumentSnapshot<Object?>>> subs;
  final _firestore = FirebaseFirestore.instance;
  _MapsState({required this.app});
  var username, email, ph, image, provider, uid;
  List<DocumentSnapshot<Map<String, dynamic>>> queryLoc = [];
  final CameraPosition _initpostion = CameraPosition(
    target: LatLng(18.9217, 72.8332),
    zoom: 17.1414,
  );
  bool cab_details = false;
  bool driver_details = false;
  String driver_token = "";
  TextEditingController reviewController = TextEditingController(text: '');
  TextEditingController reviewMessageController =
      TextEditingController(text: '');
  List l1 = [];
  bool reaching_destination = false;
  List<Marker> placeMarker = [];
  late GoogleMapController newmapcontroller;
  LatLng? curloc;
  late StreamSubscription<dynamic> driver_location_sub;
  Completer<GoogleMapController> mapcontroller = Completer();
  Map t1 = {};

  late Position currentPosition;
  List<LatLng> polylineCoordinates = [];
  late Stream<Position> Userloc;
  Map<PolylineId, Polyline> polyline = {};
  loc.Location location = new loc.Location();
  PolylinePoints polylinePoints = PolylinePoints();
  // ignore: cancel_subscriptions
  StreamSubscription<Position>? positionStream;
  StreamSubscription<Position>? getloc;
  bool loadingplace = false;
  var geoLocator = Geolocator();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  List<LatLng>? poly = [];
  Set<Polyline> _polylines = {};
  late Position position;
  String selectedCar = "Cab-UX";
  String selectedPayment = "Cash";
  var textController = TextEditingController();
  bool ismapcontrollercreated = false;
  MapPickerController mapPickerController = MapPickerController();
  bool usingmappin = false;
  bool trip_details = false;
  String pickup_lat = "";
  String pickup_long = "";
  String destination_lat = "";
  String destination_long = "";
  String user_pickup_lat = "";
  String user_image = "";
  String user_email = "";
  String user_name = "";
  String user_phone = "";
  String user_pickup_long = "";
  String user_destination_lat = "";
  String user_destination_long = "";
  String user_pickup_address = "";
  String user_destination_address = "";
  String user_trip_charge = "";
  String user_trip_distance = "";
  String user_trip_time = "";
  String user_uid = "";
  String cab_type = "";
  String trip_docid = "";
  bool isConnected = false;
  static const platform = const MethodChannel("razorpay_flutter");

  late Razorpay _razorpay;

  late Timer timer;
  late StreamSubscription<dynamic> drivers_positions_stream;
  late LatLng pickup;
  Future<void> setupnotification() async {
    print("in setup notification");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("getting data ");
      print(message.notification);
      print(message.data);
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails("chnanelId", "channellname",
              channelDescription:
                  "The Travel Treat app requires notification service to assure user and alert on required time.",
              importance: Importance.high,
              priority: Priority.high);
      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      if (message.data["type"] == "Ride Cancel") {
        print("Ride cancel ${message.data} ");
        while (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
      } else if (message.data["type"] == "Ride Accept") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isdriverpickup", true);
        prefs.setBool("reaching_destination", false);
        setState(() {
          while (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          }
          trip_details = true;
          reaching_destination = false;
          placeMarker.add(Marker(
              markerId: MarkerId("Driver_location"),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueMagenta),
              infoWindow: InfoWindow(title: "Drivers Loc"),
              position: LatLng(double.tryParse(message.data["lat"])!,
                  double.tryParse(message.data["long"])!)));
        });
        print("lat driver${message.data["lat"]}");
        String ttr = "";
        if ((int.tryParse(message.data["time"]))! / 60 < 1) {
          ttr = "1";
        } else {
          ttr = ((int.tryParse(message.data["time"]))! / 60).ceil().toString();
        }
        Driver driver = Driver(
          uid: message.data["uid"],
          username: message.data["username"],
          imageurl: message.data["imageurl"],
          timetoreach: ttr,
          phone: message.data["phone"],
          cabimage: message.data["cab_image"],
          cab_model: message.data["cab_model"],
          cab_number: message.data["cab_number"],
          rating: message.data["rating"],
          driver_token: message.data["drivers_token"],
        );

        print(
            "driverDetails ${driver.username} ${driver.imageurl} ${driver.phone}");
        Provider.of<DriverProvider>(context, listen: false)
            .updateDriver(driver);

        Get.snackbar("Got The Ride", "The driver we be avaible soon",
            duration: Duration(seconds: 4));
        timer.cancel();
        while (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
        driver_location_sub = FirebaseFirestore.instance
            .collection('Trip_in_progress')
            .doc(Provider.of<AccountProvider>(context, listen: false)
                .userAccount
                .Uid)
            .snapshots()
            .listen((event) {
          if (event.data() != null) {
            GeoPoint geoPoint = event.data()!["position"]["geopoint"];
            setState(() {
              placeMarker.removeWhere((element) {
                return element.markerId.value == "Driver_location";
              });
              placeMarker.add(Marker(
                  markerId: MarkerId("Driver_location"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueMagenta),
                  infoWindow: InfoWindow(title: "Drivers Loc"),
                  position: LatLng(geoPoint.latitude, geoPoint.longitude)));
            });
            print("geoPoint lat ${geoPoint.latitude}");
            print("geoPoint long ${geoPoint.longitude}");
          }
        });
      } else if (message.data["type"] == "Cancel Trip") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isdriverpickup", false);
        Get.snackbar("Trip Cancelled", "The driver has cancelled the trip");
        setState(() {
          placeMarker.removeWhere(
              (element) => element.markerId.value == "Driver_location");
          cab_details = true;
          driver_details = false;
          trip_details = false;
          driver_location_sub.cancel();
        });
      } else if (message.data["type"] == "Start Trip") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("reaching_destination", true);
        setState(() {
          reaching_destination = true;
        });
      } else if (message.data["type"] == "Cash Payment Approve") {
        trip_docid = message.data["docid"];
        print('Cash Payment Approve Message');
        while (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop('dialog');
        }
        Provider.of<UserData>(context, listen: false)
            .updatepickuplocation(null);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (builder) {
              return ClassicGeneralDialogWidget(
                actions: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "Trip Reviews",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                          AnimatedTextKit(
                            animatedTexts: [
                              ColorizeAnimatedText("Share Your Ride Experience",
                                  textStyle: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  colors: [
                                    Colors.grey.shade900,
                                    Colors.grey.shade300,
                                  ]),
                            ],
                            repeatForever: true,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18.0),
                                child: Image.network(
                                    "${Provider.of<DriverProvider>(context, listen: false).driver.imageurl}",
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${Provider.of<DriverProvider>(context, listen: false).driver.username}",
                                      style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  Row(
                                    children: [
                                      Icon(
                                        LineIcons.starAlt,
                                        color: Colors.amber,
                                      ),
                                      Text(
                                        "  ${Provider.of<DriverProvider>(context, listen: false).driver.rating}",
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                Consumer<RatingProvider>(
                                    builder: (context, value, _) {
                                  return RatingBarIndicator(
                                    rating: value.rating,
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 30.0,
                                    direction: Axis.horizontal,
                                  );
                                }),
                                Container(
                                  width: 80,
                                  padding: EdgeInsets.only(left: 20),
                                  child: Center(
                                    child: TextFormField(
                                      onChanged: (value) {
                                        if (double.parse(value) >= 1.0 &&
                                            double.parse(value) <= 5.0) {
                                          Provider.of<RatingProvider>(context,
                                                  listen: false)
                                              .setRating(double.parse(value));
                                        }
                                      },
                                      controller: reviewController,
                                      keyboardType: TextInputType.number,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(top: 6, left: 12),
                                        hintText: "4.3",
                                        filled: true,
                                        fillColor: Colors.grey[300],
                                        focusColor: Colors.black,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 35,
                            width: 250,
                            child: TextFormField(
                              style: GoogleFonts.montserrat(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                              controller: reviewMessageController,
                              keyboardType: TextInputType.text,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(top: 6, left: 12),
                                hintText: "Write a review",
                                hintStyle: GoogleFonts.montserrat(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                                focusColor: Colors.black,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 250,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 30),
                                      primary: Colors.black,
                                      onPrimary: Colors.white,
                                    ),
                                    onPressed: () async {
                                      if (reviewMessageController.text.trim() !=
                                          "") {
                                        var collectionReference = _firestore
                                            .collection('Trip_collection');
                                        collectionReference
                                            .doc(trip_docid)
                                            .update({
                                          "users_review":
                                              "${reviewMessageController.text.trim()}",
                                        });

                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setBool("isdriverpickup", false);

                                        setState(() {
                                          _polylines.clear();
                                          placeMarker = [];
                                          cab_details = false;
                                          driver_details = false;
                                          trip_details = false;
                                          Provider.of<PickupMarkers>(context,
                                                  listen: false)
                                              .updatePickupMarkers(null, null);
                                          Provider.of<UserData>(context,
                                                  listen: false)
                                              .updatepickuplocation(null);
                                          Provider.of<DestinationMarkers>(
                                                  context,
                                                  listen: false)
                                              .updateDestinationMarkers(
                                                  null, null);

                                          pickup_lat = "";
                                          pickup_long = "";
                                          destination_lat = "";
                                          destination_long = "";
                                          user_pickup_lat = "";
                                          user_image = "";
                                          user_name = "";
                                          user_phone = "";
                                          user_pickup_long = "";
                                          user_destination_lat = "";
                                          user_destination_long = "";
                                          user_pickup_address = "";
                                          user_destination_address = "";
                                          user_trip_charge = "";
                                          user_trip_distance = "";
                                          user_trip_time = "";
                                          user_uid = "";
                                          cab_type = "";
                                          trip_docid = "";
                                          driver_location_sub.cancel();
                                        });
                                        while (Navigator.of(context,
                                                rootNavigator: true)
                                            .canPop()) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                        }
                                        reviewMessageController.text = "";
                                      } else {
                                        _scaffoldKey.currentState!.showSnackBar(
                                          SnackBar(
                                            content:
                                                Text("Please write a review"),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text("Submit",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400))),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 30),
                                        primary: Colors.white,
                                        onPrimary: Colors.black),
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setBool("isdriverpickup", false);

                                      setState(() {
                                        _polylines.clear();
                                        placeMarker = [];
                                        cab_details = false;
                                        driver_details = false;
                                        trip_details = false;
                                        Provider.of<PickupMarkers>(context,
                                                listen: false)
                                            .updatePickupMarkers(null, null);
                                        Provider.of<DestinationMarkers>(context,
                                                listen: false)
                                            .updateDestinationMarkers(
                                                null, null);

                                        pickup_lat = "";
                                        pickup_long = "";
                                        destination_lat = "";
                                        destination_long = "";
                                        user_pickup_lat = "";
                                        user_image = "";
                                        user_name = "";
                                        user_phone = "";
                                        user_pickup_long = "";
                                        user_destination_lat = "";
                                        user_destination_long = "";
                                        user_pickup_address = "";
                                        user_destination_address = "";
                                        user_trip_charge = "";
                                        user_trip_distance = "";
                                        user_trip_time = "";
                                        user_uid = "";
                                        cab_type = "";
                                        trip_docid = "";
                                        driver_location_sub.cancel();
                                      });
                                      while (Navigator.of(context,
                                              rootNavigator: true)
                                          .canPop()) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                      }
                                    },
                                    child: Text("Cancel",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            });
      } else if (message.data["type"] == "Cash Payment Approve By Driver") {
        var trip_docid = message.data["docid"];
        var collectionReference = _firestore.collection('Trip_collection');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isdriverpickup", true);
        prefs.setBool("reaching_destination", false);
        setState(() {
          _polylines.clear();
          placeMarker = [];
          cab_details = false;
          driver_details = false;
          trip_details = false;
          Provider.of<PickupMarkers>(context, listen: false)
              .updatePickupMarkers(null, null);
          Provider.of<UserData>(context, listen: false)
              .updatepickuplocation(null);
          Provider.of<DestinationMarkers>(context, listen: false)
              .updateDestinationMarkers(null, null);
          pickup_lat = "";
          pickup_long = "";
          destination_lat = "";
          destination_long = "";
          user_pickup_lat = "";
          user_image = "";
          user_name = "";
          user_phone = "";
          user_pickup_long = "";
          user_destination_lat = "";
          user_destination_long = "";
          user_pickup_address = "";
          user_destination_address = "";
          user_trip_charge = "";
          user_trip_distance = "";
          user_trip_time = "";
          user_uid = "";
          cab_type = "";
          trip_docid = "";
          driver_location_sub.cancel();
        });
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (builder) {
              return ClassicGeneralDialogWidget(
                actions: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Trip Reviews",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 20),
                            ),
                          ),
                          AnimatedTextKit(
                            animatedTexts: [
                              ColorizeAnimatedText("Share Your Ride Experience",
                                  textStyle: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  colors: [
                                    Colors.grey.shade900,
                                    Colors.grey.shade300,
                                  ]),
                            ],
                            repeatForever: true,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18.0),
                                child: Image.network(
                                    "${Provider.of<DriverProvider>(context, listen: false).driver.imageurl}",
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${Provider.of<DriverProvider>(context, listen: false).driver.username}",
                                      style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  Row(
                                    children: [
                                      Icon(
                                        LineIcons.starAlt,
                                        color: Colors.amber,
                                      ),
                                      Text(
                                        "  ${Provider.of<DriverProvider>(context, listen: false).driver.rating}",
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                Consumer<RatingProvider>(
                                    builder: (context, value, _) {
                                  return RatingBarIndicator(
                                    rating: value.rating,
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 30.0,
                                    direction: Axis.horizontal,
                                  );
                                }),
                                Container(
                                  width: 80,
                                  padding: EdgeInsets.only(left: 20),
                                  child: Center(
                                    child: TextFormField(
                                      onChanged: (value) {
                                        if (double.parse(value) >= 1.0 &&
                                            double.parse(value) <= 5.0) {
                                          Provider.of<RatingProvider>(context,
                                                  listen: false)
                                              .setRating(double.parse(value));
                                        }
                                      },
                                      controller: reviewController,
                                      keyboardType: TextInputType.number,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(top: 6, left: 12),
                                        hintText: "4.3",
                                        filled: true,
                                        fillColor: Colors.grey[300],
                                        focusColor: Colors.black,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: 35,
                            width: 250,
                            child: TextFormField(
                              style: GoogleFonts.montserrat(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                              controller: reviewMessageController,
                              keyboardType: TextInputType.text,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(top: 6, left: 12),
                                hintText: "Write a review",
                                hintStyle: GoogleFonts.montserrat(
                                    fontSize: 15, fontWeight: FontWeight.w400),
                                focusColor: Colors.black,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 250,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 30),
                                      primary: Colors.black,
                                      onPrimary: Colors.white,
                                    ),
                                    onPressed: () async {
                                      if (reviewMessageController.text.trim() !=
                                          "") {
                                        var collectionReference = _firestore
                                            .collection('Trip_collection');

                                        collectionReference
                                            .doc(trip_docid)
                                            .update({
                                          "users_review":
                                              "${reviewMessageController.text.trim()}",
                                        }).whenComplete(() {
                                          Fluttertoast.showToast(
                                              msg: "Review added",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.black,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        });
                                        print("updated the doc");

                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setBool("isdriverpickup", false);

                                        while (Navigator.of(context,
                                                rootNavigator: true)
                                            .canPop()) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop('dialog');
                                        }
                                        reviewMessageController.text = "";
                                      } else {
                                        _scaffoldKey.currentState!.showSnackBar(
                                          SnackBar(
                                            content:
                                                Text("Please write a review"),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text("Submit",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400))),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 30),
                                        primary: Colors.white,
                                        onPrimary: Colors.black),
                                    onPressed: () async {
                                      while (Navigator.of(context,
                                              rootNavigator: true)
                                          .canPop()) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                      }
                                    },
                                    child: Text("Cancel",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            });
      } else if (message.data['type'] == "Online Payment Request from Driver") {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (builder) {
              return ClassicGeneralDialogWidget(
                actions: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    child: Column(
                      children: [
                        Text(
                          "Payment (Online)",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                        Image.asset('asset/images/online_pay.png'),
                        Text(
                          "Total Amount: ${selectedCar == "Cab-Mini" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 24 + 60).ceil().toString())}" : selectedCar == "Cab-UX" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 35 + 100).ceil().toString())}" : selectedCar == "Cab-Delux" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 42 + 150).ceil().toString())}" : ""}" +
                              " Rupee",
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextButton.icon(
                          icon: LineIcon(LineIcons.moneyBill,
                              size: 20, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.black,
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 20,
                              )),
                          onPressed: openCheckout,
                          label: Text("Pay with Razorypay",
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
      } else {
        // Navigator.of(context).pop(true);
        await FlutterLocalNotificationsPlugin()
            .show(12345, "${message.category}", "${message.data["type"]}",
                platformChannelSpecifics,
                payload: 'sending from user')
            .then((value) => print(" print done"))
            .onError((error, stackTrace) => print("got error"));
      }
    });
  }

  void track() async {
    positionStream = Geolocator.getPositionStream().listen(
      (Position position) {
        LatLng latLngPosition = LatLng(position.latitude, position.longitude);
        CameraPosition cameraPosition =
            CameraPosition(target: latLngPosition, zoom: 19);
        newmapcontroller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        print(position.toString().length == 0
            ? 'Unknown'
            : position.latitude.toString() +
                ', ' +
                position.longitude.toString());
      },
    );
  }

  Future<LatLng> locatePosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 18);
    print("latlng :-$latLngPosition");
    newmapcontroller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    return latLngPosition;
  }

  void getLocationDetails(double latitude, double longitude) async {
    dynamic res = await Geocoding().getAddress(latitude, longitude, context);
    if (res != "Failed") {
      if (Provider.of<PickupMarkers>(context, listen: false).places != null) {
        Provider.of<PickupMarkers>(context, listen: false)
            .updatePickupMarkers(null, null);
      }
      curloc = LatLng(res.lat, res.lng);

      setState(() {
        loadingplace = false;
        placeMarker = [];
        placeMarker.add(Marker(
            markerId: MarkerId("Current_location_user"),
            infoWindow: InfoWindow(title: res.placeAddres),
            position: curloc!));
      });
      if (Provider.of<DestinationMarkers>(context, listen: false).places ==
          null) {
        CameraPosition cameraPosition =
            CameraPosition(target: curloc!, zoom: 19);
        newmapcontroller.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
      } else {
        await case1();
      }
      setState(() {
        usingmappin = false;
      });
    } else {
      Get.snackbar("Location service", "Couldn't get the current location",
          duration: Duration(seconds: 4));
      setState(() {
        loadingplace = false;
      });
    }

    print(" This is -$res");
  }

  void getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    dynamic res = await Geocoding()
        .getAddress(position.latitude, position.longitude, context);
    if (res != "Failed") {
      if (Provider.of<PickupMarkers>(context, listen: false).places != null) {
        Provider.of<PickupMarkers>(context, listen: false)
            .updatePickupMarkers(null, null);
      }
      LatLng curloc = LatLng(res.lat, res.lng);
      setState(() {
        loadingplace = false;
        placeMarker = [];
        placeMarker.add(Marker(
            markerId: MarkerId("Current_location_user"),
            infoWindow: InfoWindow(title: res.placeAddres),
            position: curloc));

        if (Provider.of<DestinationMarkers>(context, listen: false).places ==
            null) {
          CameraPosition cameraPosition =
              CameraPosition(target: curloc, zoom: 19);
          newmapcontroller.animateCamera(
            CameraUpdate.newCameraPosition(cameraPosition),
          );
        } else {
          case1();
        }
      });
    } else {
      Get.snackbar("Location service", "Couldn't get the current location",
          duration: Duration(seconds: 4));
      setState(() {
        loadingplace = false;
      });
    }

    print(" This is -$res");
  }

  void logoutgoogleuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('Username');
    await prefs.remove('Email');
    await prefs.remove('Ph');
    await prefs.remove('Uid');
    try {
      await prefs.remove('Image');
    } catch (e) {}
    try {
      await GoogleSignIn().signOut();
    } catch (e) {}
    await FirebaseAuth.instance.signOut();
    if (Provider.of<ImageData>(context, listen: false).image != null) {
      Provider.of<ImageData>(context, listen: false).updateimage(null);
    }
    UserAccount userAccount = UserAccount(
        Email: "",
        Image: "",
        Ph: "",
        Uid: "",
        Username: "",
        emph: "",
        rating: "");
    Provider.of<AccountProvider>(context, listen: false)
        .updateuseraccount(userAccount);
    Provider.of<UserData>(context, listen: false).updatepickuplocation(null);
    Provider.of<PickupMarkers>(context, listen: false)
        .updatePickupMarkers(null, null);
    Provider.of<DestinationMarkers>(context, listen: false)
        .updateDestinationMarkers(null, null);

    Get.off(
      Welcome(app: app),
    );
  }

  Future<void> checkisinmidtrip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("checkisinmidtrip");
    var response = prefs.getBool("isdriverpickup");
    var reaching = prefs.getBool("reaching_destination") ?? false;
    print("response :${response}");

    if (response != null && response == true) {
      _firestore
          .collection('Trip_in_progress')
          .doc(Provider.of<AccountProvider>(context, listen: false)
              .userAccount
              .Uid)
          .get()
          .then((value) async {
        print("the trip data :${value.data()}");
        Get.snackbar("trip data",
            "${value.data()!['carDetails']['usersDetails']['user_name']}");
        if (value.data() != null) {
          print("Updating all the value");
          setState(() {
            reaching_destination = reaching;
            trip_details = true;
            user_pickup_lat =
                value.data()!['carDetails']['usersDetails']['user_pickup_lat'];
            user_image =
                value.data()!['carDetails']['usersDetails']['user_image'];
            user_name =
                value.data()!['carDetails']['usersDetails']['user_name'];
            user_phone =
                value.data()!['carDetails']['usersDetails']['user_phone'];
            user_pickup_lat =
                value.data()!['carDetails']['usersDetails']['user_pickup_lat'];
            user_pickup_long =
                value.data()!['carDetails']['usersDetails']['user_pickup_long'];
            user_destination_lat = value.data()!['carDetails']['usersDetails']
                ['user_destination_lat'];
            user_destination_long = value.data()!['carDetails']['usersDetails']
                ['user_destination_long'];
            user_pickup_address = value.data()!['carDetails']['usersDetails']
                ['user_pickup_address'];
            user_destination_address = value.data()!['carDetails']
                ['usersDetails']['user_destination_address'];
            user_trip_charge =
                value.data()!['carDetails']['usersDetails']['user_trip_charge'];
            user_trip_distance = value.data()!['carDetails']['usersDetails']
                ['user_trip_distance'];
            user_trip_time =
                value.data()!['carDetails']['usersDetails']['user_trip_time'];
            user_uid = value.data()!['carDetails']['usersDetails']['user_uid'];
            selectedCar =
                value.data()!['carDetails']['usersDetails']['cab_type'];
            selectedPayment =
                value.data()!['carDetails']['usersDetails']['payment_type'];
            user_email =
                value.data()!['carDetails']['usersDetails']['user_email'];
            pickup = LatLng(double.tryParse(user_pickup_lat)!,
                double.tryParse(user_pickup_long)!);
            LatLng destination = LatLng(double.tryParse(user_destination_lat)!,
                double.tryParse(user_destination_long)!);
            placeMarker.add(
              Marker(
                markerId: MarkerId("Pick_up"),
                infoWindow: InfoWindow(title: "Pick up place"),
                position: pickup,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
            );
            placeMarker.add(
              Marker(
                markerId: MarkerId("Destination"),
                infoWindow: InfoWindow(title: "Destination place"),
                position: destination,
              ),
            );
            print("user_uid :${user_uid}");
            print("user_trip_charge :${user_trip_charge}");
            print("user_trip_distance :${user_trip_distance}");
            print("user_trip_time :${user_trip_time}");
            print("user_pickup_lat :${user_pickup_lat}");
            print("user_pickup_long :${user_pickup_long}");
            print("user_destination_lat :${user_destination_lat}");
            print("user_destination_long :${user_destination_long}");
            print("user_pickup_address :${user_pickup_address}");
            print("user_destination_address :${user_destination_address}");
            print("user_image :${user_image}");
            print("user_name :${user_name}");
            print("user_phone :${user_phone}");
            print("selected :${selectedCar}");
            print("selected :$user_email");
            print("pickup :${pickup}");

            var driver_uid = value.data()!['uid'];

            var driver_username = value.data()!['username'];
            var driver_phone = value.data()!['driverDetails']['phone'];
            var driver_profile = value.data()!['driverDetails']['imageurl'];
            var driver_raring = value.data()!['driverDetails']['rating'];
            var driver_cabimage = value.data()!['carDetails']['carImage'];
            var driver_cabmodel = value.data()!['carDetails']['carModel'];
            var driver_carnumber = value.data()!['carDetails']['carNumber'];
            var driver_token = value.data()!['driverDetails']['driver_token'];
            Driver driver = Driver(
              cabimage: driver_cabimage,
              uid: driver_uid,
              username: driver_username,
              imageurl: driver_profile,
              phone: driver_phone,
              cab_model: driver_cabmodel,
              cab_number: driver_carnumber,
              rating: driver_raring,
              driver_token: driver_token,
            );
            Provider.of<DriverProvider>(context, listen: false)
                .updateDriver(driver);
          });
          var collectionReference = _firestore.collection('Trip_in_progress');
          try {
            String token = await FirebaseMessaging.instance.getToken() ?? "";
            driver_location_sub = FirebaseFirestore.instance
                .collection('Trip_in_progress')
                .doc(Provider.of<AccountProvider>(context, listen: false)
                    .userAccount
                    .Uid)
                .snapshots()
                .listen((event) {
              if (event.data() != null) {
                GeoPoint geoPoint = event.data()!["position"]["geopoint"];
                setState(() {
                  placeMarker.removeWhere((element) {
                    return element.markerId.value == "Driver_location";
                  });
                  placeMarker.add(Marker(
                      markerId: MarkerId("Driver_location"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueMagenta),
                      infoWindow: InfoWindow(title: "Drivers Loc"),
                      position: LatLng(geoPoint.latitude, geoPoint.longitude)));
                });
                print("geoPoint lat ${geoPoint.latitude}");
                print("geoPoint long ${geoPoint.longitude}");
              }
            });
          } catch (e) {
            print("Error: $e");
          }
          Directions directions = Directions(
              endpoint: "FindDrivingPath",
              origin: "$user_pickup_lat,$user_pickup_long",
              destination: "$user_destination_lat,$user_destination_long",
              context: context);
          try {
            poly = await directions.getDirections();
            print("polyline direction:${poly}");

            print("poly:$poly");
            if (poly != null) {
              setState(() {
                cab_details = true;
                _polylines = {
                  Polyline(
                      width: 3,
                      polylineId: PolylineId("Travel_path"),
                      color: Colors.black,
                      jointType: JointType.bevel,
                      points: Provider.of<DirectionsProvider>(context,
                              listen: false)
                          .cordinates_collections!)
                };

                // CameraPosition
                CameraPosition cameraPosition =
                    CameraPosition(target: pickup, zoom: 18);
                newmapcontroller.animateCamera(
                  CameraUpdate.newLatLngBounds(
                      Provider.of<DirectionsProvider>(context, listen: false)
                          .bounds!,
                      65.0),
                );
                Provider.of<PickupMarkers>(context, listen: false)
                    .updatePickupMarkers(
                        LatLng(double.tryParse(user_pickup_lat)!,
                            double.tryParse(user_pickup_long)!),
                        user_pickup_address);
                Provider.of<DestinationMarkers>(context, listen: false)
                    .updateDestinationMarkers(
                        LatLng(double.tryParse(user_destination_lat)!,
                            double.tryParse(user_destination_long)!),
                        user_destination_address);
                pickup = LatLng(double.tryParse(user_pickup_lat)!,
                    double.tryParse(user_pickup_long)!);
              });
              setState(() {
                cab_details = true;
                driver_details = true;
                trip_details = true;
              });
            } else {
              setState(() {
                cab_details = false;
                _polylines = {};
                Provider.of<DestinationMarkers>(context, listen: false)
                    .updateDestinationMarkers(null, null);
                print("place marker ${placeMarker}");
                placeMarker.removeWhere(
                    (element) => element.markerId.value == "Destination");
                CameraPosition cameraPosition =
                    CameraPosition(target: pickup, zoom: 18);
                newmapcontroller.animateCamera(
                    CameraUpdate.newCameraPosition(cameraPosition));
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    useSafeArea: true,
                    builder: (builder) {
                      return CupertinoAlertDialog(
                        title: Text(
                          "Location Error",
                          style: GoogleFonts.montserrat(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        content: Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset(
                                  "asset/images/Location_error.png",
                                  height: 100,
                                  width: 100,
                                ),
                                Text(
                                  "Please try valid location",
                                  style: GoogleFonts.montserrat(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton.icon(
                            icon: Icon(Icons.close),
                            label: Text("Close"),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    });
                // CameraPosition
              });
            }
          } catch (e) {
            print("Error: $e");
          }
        }
      });
    }
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_RobwZdG6whhfk4',
      'amount': int.tryParse(user_trip_charge)! * 100,
      'name': 'Travel treat.',
      'description': 'Cab service',
      'prefill': {'contact': user_phone, 'email': user_email},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    while (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
    DateTime now = DateTime.now();
    var current_time = now.toLocal().toString();
    var collectionReference = _firestore.collection('Trip_collection');
    trip_docid =
        Provider.of<AccountProvider>(context, listen: false).userAccount.Uid +
            "_" +
            current_time;
    print("trip_docid:$trip_docid");
    print('Online Payment Done Successfully');
    setState(() {
      driver_location_sub.cancel();
      Provider.of<PickupMarkers>(context, listen: false)
          .updatePickupMarkers(null, null);
      Provider.of<UserData>(context, listen: false).updatepickuplocation(null);
    });
    collectionReference.doc(trip_docid).set({'trip_end_time': current_time});
    Msg()
        .sendOnlinePaymentisDone(
            Provider.of<DriverProvider>(context, listen: false)
                .driver
                .driver_token,
            trip_docid)
        .then((e) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (builder) {
            return ClassicGeneralDialogWidget(
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Trip Reviews",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                        ),
                        AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText("Share Your Ride Experience",
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                colors: [
                                  Colors.grey.shade900,
                                  Colors.grey.shade300,
                                ]),
                          ],
                          repeatForever: true,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18.0),
                              child: Image.network(
                                  "${Provider.of<DriverProvider>(context, listen: false).driver.imageurl}",
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "${Provider.of<DriverProvider>(context, listen: false).driver.username}",
                                    style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                Row(
                                  children: [
                                    Icon(
                                      LineIcons.starAlt,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      "  ${Provider.of<DriverProvider>(context, listen: false).driver.rating}",
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              Consumer<RatingProvider>(
                                  builder: (context, value, _) {
                                return RatingBarIndicator(
                                  rating: value.rating,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 30.0,
                                  direction: Axis.horizontal,
                                );
                              }),
                              Container(
                                width: 80,
                                padding: EdgeInsets.only(left: 20),
                                child: Center(
                                  child: TextFormField(
                                    onChanged: (value) {
                                      if (double.parse(value) >= 1.0 &&
                                          double.parse(value) <= 5.0) {
                                        Provider.of<RatingProvider>(context,
                                                listen: false)
                                            .setRating(double.parse(value));
                                      }
                                    },
                                    controller: reviewController,
                                    keyboardType: TextInputType.number,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(top: 6, left: 12),
                                      hintText: "4.3",
                                      filled: true,
                                      fillColor: Colors.grey[300],
                                      focusColor: Colors.black,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 35,
                          width: 250,
                          child: TextFormField(
                            style: GoogleFonts.montserrat(
                                fontSize: 15, fontWeight: FontWeight.w400),
                            controller: reviewMessageController,
                            keyboardType: TextInputType.text,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: 6, left: 12),
                              hintText: "Write a review",
                              hintStyle: GoogleFonts.montserrat(
                                  fontSize: 15, fontWeight: FontWeight.w400),
                              focusColor: Colors.black,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 30),
                                    primary: Colors.black,
                                    onPrimary: Colors.white,
                                  ),
                                  onPressed: () async {
                                    if (reviewMessageController.text.trim() !=
                                        "") {
                                      var collectionReference = _firestore
                                          .collection('Trip_collection');

                                      collectionReference
                                          .doc(trip_docid)
                                          .update({
                                        "users_review":
                                            "${reviewMessageController.text.trim()}",
                                      }).whenComplete(() {
                                        Fluttertoast.showToast(
                                            msg: "Review added",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      });
                                      print("updated the doc");

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setBool("isdriverpickup", false);

                                      setState(() {
                                        pickup_lat = "";
                                        pickup_long = "";
                                        destination_lat = "";
                                        destination_long = "";
                                        user_pickup_lat = "";
                                        user_image = "";
                                        user_name = "";
                                        user_phone = "";
                                        user_pickup_long = "";
                                        user_destination_lat = "";
                                        user_destination_long = "";
                                        user_pickup_address = "";
                                        user_destination_address = "";
                                        user_trip_charge = "";
                                        user_trip_distance = "";
                                        user_trip_time = "";
                                        user_uid = "";
                                        cab_type = "";
                                        trip_docid = "";
                                      });
                                      while (Navigator.of(context,
                                              rootNavigator: true)
                                          .canPop()) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                      }
                                      reviewMessageController.text = "";
                                    } else {
                                      _scaffoldKey.currentState!.showSnackBar(
                                        SnackBar(
                                          content:
                                              Text("Please write a review"),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text("Submit",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400))),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 30),
                                      primary: Colors.white,
                                      onPrimary: Colors.black),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setBool("isdriverpickup", false);

                                    setState(() {
                                      _polylines.clear();
                                      placeMarker = [];
                                      cab_details = false;
                                      driver_details = false;
                                      trip_details = false;
                                      Provider.of<PickupMarkers>(context,
                                              listen: false)
                                          .updatePickupMarkers(null, null);
                                      Provider.of<DestinationMarkers>(context,
                                              listen: false)
                                          .updateDestinationMarkers(null, null);

                                      pickup_lat = "";
                                      pickup_long = "";
                                      destination_lat = "";
                                      destination_long = "";
                                      user_pickup_lat = "";
                                      user_image = "";
                                      user_name = "";
                                      user_phone = "";
                                      user_pickup_long = "";
                                      user_destination_lat = "";
                                      user_destination_long = "";
                                      user_pickup_address = "";
                                      user_destination_address = "";
                                      user_trip_charge = "";
                                      user_trip_distance = "";
                                      user_trip_time = "";
                                      user_uid = "";
                                      cab_type = "";
                                      trip_docid = "";
                                      driver_location_sub.cancel();
                                    });
                                    while (Navigator.of(context,
                                            rootNavigator: true)
                                        .canPop()) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    }
                                  },
                                  child: Text("Cancel",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          });
    });
    setState(() {
      placeMarker = [];
      _polylines = {};
      cab_details = false;
      driver_details = false;
      trip_details = false;
      Provider.of<PickupMarkers>(context, listen: false)
          .updatePickupMarkers(null, null);
      Provider.of<DestinationMarkers>(context, listen: false)
          .updateDestinationMarkers(null, null);
      driver_location_sub.cancel();
    });

    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!, toastLength: Toast.LENGTH_LONG);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        toastLength: Toast.LENGTH_SHORT);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT);
  }

  Future<void> dr() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isdriverpickup", true);
  }

  @override
  void initState() {
    dr();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print("init");
    Provider.of<Connection>(context, listen: false).getDataConnection();

    setupnotification();
    print("isConnected:$isConnected");

    getData();
    checkisinmidtrip();

    super.initState();
  }

  Future<void> getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      username = prefs.get("Username");
      email = prefs.get("Email");
      ph = prefs.get("Ph");
      image = prefs.get("Image");
      uid = prefs.get("Uid");
      print(
          "Username :- $username,Email :- $email,phone number :- $ph,Image :- $image,Uid :- $uid");
    } catch (e) {
      print(e);
    }
  }

  void getDriverDeatials() async {
    if (getloc != null) {
      getloc!.cancel();
    }
    var cab_class;
    if (selectedCar == "Cab-Mini") {
      cab_class = "3";
    } else if (selectedCar == "Cab-UX") {
      cab_class = "2";
    } else {
      cab_class = "1";
    }
    var collectionReference = _firestore
        .collection('Test_Loc')
        .where("carDetails.class", isEqualTo: cab_class);
    var geoRef = geo.collection(collectionRef: collectionReference);
    // Userloc = Geolocator.getPositionStream();
    GeoFirePoint current =
        geo.point(latitude: position.latitude, longitude: position.longitude);

    Stream<List<DocumentSnapshot<Map<String, dynamic>>>> data = geoRef.within(
      center: current,
      radius: 5,
      field: 'position',
      strictMode: true,
    );
    subs = data.listen(
      (queryLoc) {
        l1 = [];
        print('querylocation ${queryLoc})}');
        print('length:${queryLoc.length}');

        for (int i = 0; i < queryLoc.length; i++) {
          bool a = queryLoc.elementAt(i).data()!["driverDetails"] != null;
          if (a) {
            String driversuid = queryLoc.elementAt(i).data()!["uid"];
            String token = queryLoc.elementAt(i).data()!["token"];
            Map t1 = queryLoc.elementAt(i).data()!["driverDetails"];

            List temp_list = [
              t1['imageurl'],
              t1['username'],
              t1['rating'],
              token,
              driversuid
            ];
            l1.add(temp_list);
            print('elementAt:${t1}');
          }
        }
        print("l1 data:${l1}");

        print("length of the t1:${t1.length}");
        setState(() {
          driver_details = true;
        });

        subs.cancel();
      },
      onDone: () {
        print('The streaming is complelte');
      },
      cancelOnError: true,
      onError: (e) {
        print('Got Error');
      },
    );
  }

  @override
  void dispose() {
    if (getloc != null) {
      getloc!.cancel();
    }
    try {
      driver_location_sub.cancel();
    } catch (e) {}
    _razorpay.clear();
    super.dispose();
  }

  Future<void> caseforpin() async {
    print("CASE -1 HERE");
    LatLng pickup = Provider.of<PickupMarkers>(context, listen: false).places !=
            null
        ? Provider.of<PickupMarkers>(context, listen: false).places
        : LatLng(
            Provider.of<UserData>(context, listen: false).pickuplocation!.lat,
            Provider.of<UserData>(context, listen: false).pickuplocation!.lng);
    pickup_lat = pickup.latitude.toString();
    pickup_long = pickup.longitude.toString();
    String pickupaddress =
        Provider.of<PickupMarkers>(context, listen: false).places != null
            ? Provider.of<PickupMarkers>(context, listen: false).address
            : Provider.of<UserData>(context, listen: false)
                .pickuplocation!
                .placeAddres;

    LatLng destination =
        Provider.of<DestinationMarkers>(context, listen: false).places;
    destination_lat = destination.latitude.toString();
    destination_long = destination.longitude.toString();
    String destinationaddress =
        Provider.of<DestinationMarkers>(context, listen: false).address;
    setState(() {
      placeMarker = [];
      placeMarker.add(
        Marker(
          markerId: MarkerId("Pick_up"),
          infoWindow: InfoWindow(title: "Pick up place"),
          position: pickup,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      placeMarker.add(
        Marker(
          markerId: MarkerId("Destination"),
          infoWindow: InfoWindow(title: destinationaddress),
          position: destination,
        ),
      );
    });
    Directions directions = Directions(
        endpoint: "FindDrivingPath",
        origin: "${pickup.latitude},${pickup.longitude}",
        destination: "${destination.latitude},${destination.longitude}",
        context: context);
    try {
      poly = await directions.getDirections();
      print("polyline direction:${poly}");

      print("poly:$poly");
      if (poly != null) {
        setState(() {
          cab_details = true;
          _polylines = {
            Polyline(
                width: 3,
                polylineId: PolylineId("Travel_path"),
                color: Colors.black,
                jointType: JointType.bevel,
                points: Provider.of<DirectionsProvider>(context, listen: false)
                    .cordinates_collections!)
          };

          // CameraPosition
          CameraPosition cameraPosition =
              CameraPosition(target: pickup, zoom: 18);
          newmapcontroller.animateCamera(
            CameraUpdate.newLatLngBounds(
                Provider.of<DirectionsProvider>(context, listen: false).bounds!,
                65.0),
          );
        });
      } else {
        setState(() {
          cab_details = false;
          _polylines = {};
          Provider.of<DestinationMarkers>(context, listen: false)
              .updateDestinationMarkers(null, null);
          print("place marker ${placeMarker}");
          placeMarker.removeWhere(
              (element) => element.markerId.value == "Destination");
          CameraPosition cameraPosition =
              CameraPosition(target: pickup, zoom: 18);
          newmapcontroller
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          showDialog(
              context: context,
              barrierDismissible: false,
              useSafeArea: true,
              builder: (builder) {
                return CupertinoAlertDialog(
                  title: Text(
                    "Location Error",
                    style: GoogleFonts.montserrat(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  content: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            "asset/images/Location_error.png",
                            height: 100,
                            width: 100,
                          ),
                          Text(
                            "Please try valid location",
                            style: GoogleFonts.montserrat(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton.icon(
                      icon: Icon(Icons.close),
                      label: Text("Close"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
          // CameraPosition
        });
      }
    } catch (e) {
      print("errors $e");
    }
  }

  Future<void> case1() async {
    print("CASE -1 HERE");
    pickup = Provider.of<PickupMarkers>(context, listen: false).places != null
        ? Provider.of<PickupMarkers>(context, listen: false).places
        : LatLng(
            Provider.of<UserData>(context, listen: false).pickuplocation!.lat,
            Provider.of<UserData>(context, listen: false).pickuplocation!.lng);
    pickup_lat = pickup.latitude.toString();
    pickup_long = pickup.longitude.toString();
    String pickupaddress =
        Provider.of<PickupMarkers>(context, listen: false).places != null
            ? Provider.of<PickupMarkers>(context, listen: false).address
            : Provider.of<UserData>(context, listen: false)
                .pickuplocation!
                .placeAddres;

    LatLng destination =
        Provider.of<DestinationMarkers>(context, listen: false).places;
    String destinationaddress =
        Provider.of<DestinationMarkers>(context, listen: false).address;
    destination_lat = destination.latitude.toString();
    destination_long = destination.longitude.toString();
    setState(() {
      placeMarker = [];
      placeMarker.add(
        Marker(
          markerId: MarkerId("Pick_up"),
          infoWindow: InfoWindow(title: "Pick up place"),
          position: pickup,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      placeMarker.add(
        Marker(
          markerId: MarkerId("Destination"),
          infoWindow: InfoWindow(title: destinationaddress),
          position: destination,
        ),
      );
    });
    Directions directions = Directions(
        endpoint: "FindDrivingPath",
        origin: "${pickup.latitude},${pickup.longitude}",
        destination: "${destination.latitude},${destination.longitude}",
        context: context);
    try {
      poly = await directions.getDirections();
      print("poly:$poly");
      if (poly != null) {
        setState(() {
          cab_details = true;
          _polylines = {
            Polyline(
                width: 3,
                polylineId: PolylineId("Travel_path"),
                color: Colors.black,
                jointType: JointType.bevel,
                points: Provider.of<DirectionsProvider>(context, listen: false)
                    .cordinates_collections!)
          };

          // CameraPosition
          CameraPosition cameraPosition =
              CameraPosition(target: pickup, zoom: 18);
          newmapcontroller.animateCamera(
            CameraUpdate.newLatLngBounds(
                Provider.of<DirectionsProvider>(context, listen: false).bounds!,
                65.0),
          );
        });
      } else {
        setState(() {
          cab_details = false;
          _polylines = {};
          Provider.of<DestinationMarkers>(context, listen: false)
              .updateDestinationMarkers(null, null);
          print("place marker ${placeMarker}");
          placeMarker.removeWhere(
              (element) => element.markerId.value == "Destination");
          CameraPosition cameraPosition =
              CameraPosition(target: pickup, zoom: 18);
          newmapcontroller
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          showDialog(
              context: context,
              barrierDismissible: false,
              useSafeArea: true,
              builder: (builder) {
                return CupertinoAlertDialog(
                  title: Text(
                    "Location Error",
                    style: GoogleFonts.montserrat(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  content: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            "asset/images/Location_error.png",
                            height: 100,
                            width: 100,
                          ),
                          Text(
                            "Please try valid location",
                            style: GoogleFonts.montserrat(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton.icon(
                      icon: Icon(Icons.close),
                      label: Text("Close"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });

          // CameraPosition
        });
      }
    } catch (e) {
      print("errors $e");
    }
  }

  Widget profile() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.96,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Color.fromRGBO(30, 30, 30, 1),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Hero(
                  tag: "profile",
                  child: Center(
                      child: CircularProfileAvatar(
                    '''https://ugxqtrototfqtawjhnol.supabase.in/storage/v1/object/public/travel-treat-storage/Users/${Provider.of<AccountProvider>(context, listen: false).userAccount.Uid}/${Provider.of<AccountProvider>(context, listen: false).userAccount.Uid}''',
                    imageFit: BoxFit.cover,
                    radius: 65,
                    cacheImage: true,
                    initialsText: Text(
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .Username
                            .substring(0, 1)),
                    onTap: () {
                      Get.to(Accounts());
                    },
                  )),
                ),
                SizedBox(
                  height: 35,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .Username,
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LineIcons.starAlt,
                            color: Colors.amber,
                          ),
                          Text(
                            " ${Provider.of<AccountProvider>(context, listen: false).userAccount.rating}",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  Provider.of<AccountProvider>(context, listen: false)
                      .userAccount
                      .Email,
                  style:
                      GoogleFonts.openSans(fontSize: 13, color: Colors.white),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
              color: Colors.black,
            ),
            title: Text(
              'Log Out',
              style: GoogleFonts.openSans(fontSize: 15, color: Colors.black),
            ),
            selected: false,
            onTap: () {
              logoutgoogleuser();
            },
          ),
        ],
      ),
    );
  }

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(41.311158, 69.279737),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    location.enableBackgroundMode(enable: true);
    super.build(context);
    print('rebuilding the widget');
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          elevation: 1,
          child: SingleChildScrollView(
            child: Column(
              children: [
                profile(),
              ],
            ),
          ),
        ),
        body: Flex(direction: Axis.vertical, children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                    height: (MediaQuery.of(context).size.height * 0.80) * 2,
                    child: Column(
                      children: [
                        Visibility(
                          visible: usingmappin,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.83,
                            child: Stack(
                              children: [
                                MapPicker(
                                  iconWidget: Image.asset(
                                    'asset/images/location pin.png',
                                    width: 30,
                                    height: 30,
                                  ),
                                  mapPickerController: mapPickerController,
                                  child: GoogleMap(
                                    mapType: MapType.normal,
                                    indoorViewEnabled: false,
                                    minMaxZoomPreference:
                                        MinMaxZoomPreference.unbounded,
                                    initialCameraPosition: _initpostion,
                                    myLocationButtonEnabled: true,
                                    myLocationEnabled: true,
                                    zoomGesturesEnabled: true,
                                    zoomControlsEnabled: true,
                                    compassEnabled: false,
                                    mapToolbarEnabled: true,
                                    markers: Set.from(placeMarker),
                                    trafficEnabled: false,
                                    buildingsEnabled: true,
                                    polylines: _polylines,
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      controller.setMapStyle(mapstyle);
                                      newmapcontroller = controller;
                                      print("Locating ");
                                      locatePosition();
                                    },
                                    onCameraMoveStarted: () {
                                      // notify map is moving
                                      mapPickerController.mapMoving!();
                                      textController.text = "checking ...";
                                    },
                                    onCameraMove: (cameraPosition) {
                                      this.cameraPosition = cameraPosition;
                                    },
                                    onCameraIdle: () async {
                                      mapPickerController.mapFinishedMoving!();

                                      print("here :${cameraPosition.target.latitude} ," +
                                          "${cameraPosition.target.longitude}");
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 60,
                                  left: 24,
                                  right: 24,
                                  child: Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 60),
                                    child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.grey[850],
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        child: const Text(
                                          "Pic location",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.normal,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onPressed: () {
                                          print(
                                              "Location ${cameraPosition.target.latitude} ${cameraPosition.target.longitude}");
                                          print(
                                              "Address: ${textController.text}");
                                          getLocationDetails(
                                              cameraPosition.target.latitude,
                                              cameraPosition.target.longitude);
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !usingmappin,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.83,
                            child: GoogleMap(
                              mapType: MapType.normal,
                              indoorViewEnabled: false,
                              minMaxZoomPreference:
                                  MinMaxZoomPreference.unbounded,
                              initialCameraPosition: _initpostion,
                              myLocationButtonEnabled: true,
                              myLocationEnabled: true,
                              zoomGesturesEnabled: true,
                              zoomControlsEnabled: true,
                              compassEnabled: false,
                              mapToolbarEnabled: true,
                              markers: Set.from(placeMarker),
                              trafficEnabled: false,
                              buildingsEnabled: true,
                              polylines: _polylines,
                              onMapCreated: (GoogleMapController controller) {
                                controller.setMapStyle(mapstyle);
                                if (!ismapcontrollercreated) {
                                  mapcontroller.complete(controller);
                                }
                                ismapcontrollercreated = true;
                                newmapcontroller = controller;
                                print("Locating ");
                                if (Provider.of<PickupMarkers>(context,
                                            listen: false)
                                        .address ==
                                    null) {
                                  locatePosition();
                                } else {
                                  CameraPosition cameraPosition =
                                      CameraPosition(target: curloc!, zoom: 19);
                                  controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        cameraPosition),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    )),
                cab_details && !trip_details
                    ? Padding(
                        padding: const EdgeInsets.only(top: 90, left: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, .7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            tooltip: "Cancel",
                            onPressed: () async {
                              Position? currentLoc =
                                  await Geolocator.getLastKnownPosition();
                              if (currentLoc == null) {
                                currentLoc =
                                    await Geolocator.getCurrentPosition();
                              }
                              setState(
                                () {
                                  trip_details = false;
                                  cab_details = false;
                                  Provider.of<DestinationMarkers>(context,
                                          listen: false)
                                      .updateDestinationMarkers(null, null);
                                  Provider.of<PickupMarkers>(context,
                                          listen: false)
                                      .updatePickupMarkers(null, null);
                                  Provider.of<UserData>(context, listen: false)
                                      .updatepickuplocation(null);
                                  _polylines = {};
                                  placeMarker = [];
                                  CameraPosition _pos = CameraPosition(
                                      target: LatLng(currentLoc!.latitude,
                                          currentLoc.longitude),
                                      zoom: 18);
                                  newmapcontroller.animateCamera(
                                    CameraUpdate.newCameraPosition(_pos),
                                  );
                                  if (getloc != null) {
                                    getloc!.cancel();
                                  }
                                },
                              );
                            },
                            icon: Icon(Icons.cancel_outlined),
                          ),
                        ),
                      )
                    : Container(),
                DraggableScrollableSheet(
                  initialChildSize: 0.45,
                  minChildSize: 0.138,
                  maxChildSize: 0.55,
                  builder: (BuildContext buildContext,
                      ScrollController scrollController) {
                    return Consumer<Connection>(
                        builder: (context, connection, _) {
                      return connection.isConnected
                          ? !cab_details
                              ? Container(
                                  height: 250.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(18.0),
                                      topRight: Radius.circular(18.0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.3),
                                        blurRadius: 16.5,
                                        spreadRadius: 0.5,
                                      )
                                    ],
                                  ),
                                  child: ListView(
                                    controller: scrollController,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0, vertical: 18.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Icon(
                                                Icons.keyboard_arrow_up_rounded,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                              height: 35.0,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.3),
                                                    blurRadius: 6.0,
                                                    spreadRadius: 0.5,
                                                    offset: Offset(0.7, 0.7),
                                                  )
                                                ],
                                              ),
                                              child: OpenContainer(
                                                  middleColor: Colors.white,
                                                  transitionType:
                                                      ContainerTransitionType
                                                          .fade,
                                                  transitionDuration: Duration(
                                                      milliseconds: 600),
                                                  closedBuilder:
                                                      (context, action) {
                                                    return Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 9),
                                                          child: Icon(
                                                              Icons.search,
                                                              color: Colors
                                                                  .blueGrey),
                                                        ),
                                                        SizedBox(
                                                          width: 10.0,
                                                        ),
                                                        Text(
                                                            'Search location / destination',
                                                            style: GoogleFonts
                                                                .openSans()),
                                                      ],
                                                    );
                                                  },
                                                  openBuilder:
                                                      (context, action) {
                                                    return SearchPlace(
                                                      app: app,
                                                      onPlaceSelect: () async {
                                                        setState(() {
                                                          _polylines = {};
                                                        });
                                                        if (Provider.of<DestinationMarkers>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .places !=
                                                                    null &&
                                                                Provider.of<PickupMarkers>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .places !=
                                                                    null ||
                                                            Provider.of<UserData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .pickuplocation !=
                                                                null) {
                                                          await case1();
                                                        } else if (Provider.of<
                                                                            DestinationMarkers>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .places ==
                                                                null &&
                                                            Provider.of<PickupMarkers>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .places !=
                                                                null) {
                                                          printInfo(
                                                              info: "CASE -2");
                                                          LatLng pickup =
                                                              Provider.of<PickupMarkers>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .places;

                                                          if (pickup
                                                              .toString()
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              placeMarker = [];
                                                              String
                                                                  pickupaddres =
                                                                  Provider.of<PickupMarkers>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .address;
                                                              placeMarker.add(Marker(
                                                                  markerId:
                                                                      MarkerId(
                                                                          "Pick_up"),
                                                                  infoWindow: InfoWindow(
                                                                      title: pickupaddres
                                                                          .toString()),
                                                                  position:
                                                                      pickup));
                                                            });
                                                            CameraPosition
                                                                cameraPosition =
                                                                CameraPosition(
                                                                    target:
                                                                        pickup,
                                                                    zoom: 18);
                                                            newmapcontroller
                                                                .animateCamera(
                                                              CameraUpdate
                                                                  .newCameraPosition(
                                                                      cameraPosition),
                                                            );
                                                          }
                                                        } else if (Provider.of<
                                                                            PickupMarkers>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .places ==
                                                                null &&
                                                            Provider.of<DestinationMarkers>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .places !=
                                                                null) {
                                                          printInfo(
                                                              info: "CASE -3");
                                                          LatLng destination =
                                                              Provider.of<DestinationMarkers>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .places;

                                                          if (destination
                                                              .toString()
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              placeMarker = [];
                                                              String
                                                                  destinationaddres =
                                                                  Provider.of<DestinationMarkers>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .address;
                                                              placeMarker.add(Marker(
                                                                  markerId:
                                                                      MarkerId(
                                                                          "Destination"),
                                                                  infoWindow:
                                                                      InfoWindow(
                                                                          title:
                                                                              destinationaddres),
                                                                  position:
                                                                      destination));
                                                            });
                                                            CameraPosition
                                                                cameraPosition =
                                                                CameraPosition(
                                                                    target:
                                                                        destination,
                                                                    zoom: 18);
                                                            newmapcontroller
                                                                .animateCamera(
                                                              CameraUpdate
                                                                  .newCameraPosition(
                                                                      cameraPosition),
                                                            );
                                                          }
                                                        } else if (Provider.of<
                                                                            PickupMarkers>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .places ==
                                                                null &&
                                                            Provider.of<DestinationMarkers>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .places ==
                                                                null) {
                                                          print(
                                                              "NO PLACE IS SELECTED ");
                                                        }
                                                      },
                                                    );
                                                  }),
                                            ),
                                            SizedBox(
                                              height: 24.0,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_rounded,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(
                                                  width: 12.0,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 275,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: 220,
                                                            child: loadingplace
                                                                ? Center(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          25,
                                                                      width: 25,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        color: Colors
                                                                            .black87,
                                                                        strokeWidth:
                                                                            2.5,
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Text(
                                                                    Provider.of<UserData>(context, listen: false).pickuplocation ==
                                                                            null
                                                                        ? "Current Location"
                                                                        : Provider.of<UserData>(context, listen: false)
                                                                            .pickuplocation!
                                                                            .placeAddres,
                                                                    softWrap:
                                                                        true,
                                                                    style: GoogleFonts.openSans(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Colors
                                                                            .black)),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                loadingplace =
                                                                    true;
                                                              });
                                                              getCurrentLoc();
                                                            },
                                                            icon:
                                                                Icon(Icons.add),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 4.0,
                                                    ),
                                                    Text(
                                                      "Your current address (estimated)",
                                                      style:
                                                          GoogleFonts.openSans(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .black54),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Divider(
                                              height: 1.0,
                                              color: Colors.black87,
                                              thickness: 1.0,
                                            ),
                                            Material(
                                              color: Colors.white,
                                              child: InkWell(
                                                onTap: () {
                                                  print('Add Home');
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.home_rounded,
                                                        color: Colors.grey,
                                                      ),
                                                      SizedBox(
                                                        width: 12.0,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('Add home',
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          13)),
                                                          SizedBox(
                                                            height: 4.0,
                                                          ),
                                                          Text(
                                                            "Add your home location",
                                                            style: GoogleFonts
                                                                .openSans(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 12.0,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 1.0,
                                              color: Colors.black,
                                              thickness: 1.0,
                                            ),
                                            Material(
                                              color: Colors.white,
                                              child: InkWell(
                                                onTap: () async {},
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.work_rounded,
                                                        color: Colors.grey,
                                                      ),
                                                      SizedBox(
                                                        width: 12.0,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Add Work location',
                                                            style: GoogleFonts
                                                                .openSans(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        13),
                                                          ),
                                                          SizedBox(
                                                            height: 4.0,
                                                          ),
                                                          Text(
                                                            "Your office location",
                                                            style: GoogleFonts
                                                                .openSans(
                                                              color: Colors
                                                                  .grey[800],
                                                              fontSize: 12.0,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 1.0,
                                              color: Colors.black,
                                              thickness: 1.0,
                                            ),
                                            Material(
                                              color: Colors.white,
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    usingmappin = !usingmappin;
                                                  });
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.pin_drop,
                                                        color: Colors.grey,
                                                      ),
                                                      SizedBox(
                                                        width: 12.0,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text('Pin location',
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          13)),
                                                          SizedBox(
                                                            height: 4.0,
                                                          ),
                                                          Text(
                                                            "Use location pin",
                                                            style: GoogleFonts
                                                                .openSans(
                                                              color: Colors
                                                                  .grey[800],
                                                              fontSize: 12.0,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : !driver_details
                                  ? Container(
                                      height: 250.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(18.0),
                                          topRight: Radius.circular(18.0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromRGBO(0, 0, 0, 0.3),
                                            blurRadius: 16.5,
                                            spreadRadius: 0.5,
                                            offset: Offset(0.7, 0.7),
                                          )
                                        ],
                                      ),
                                      child: ListView(
                                        controller: scrollController,
                                        children: [
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.horizontal_rule_rounded,
                                                  size: 32,
                                                ),
                                                Container(
                                                  height: 35.0,
                                                  width: 300,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.4),
                                                        blurRadius: 6.0,
                                                        spreadRadius: 0.5,
                                                        offset:
                                                            Offset(0.7, 0.7),
                                                      )
                                                    ],
                                                  ),
                                                  child: OpenContainer(
                                                      middleColor: Colors.white,
                                                      transitionType:
                                                          ContainerTransitionType
                                                              .fade,
                                                      transitionDuration:
                                                          Duration(
                                                              milliseconds:
                                                                  600),
                                                      closedBuilder:
                                                          (context, action) {
                                                        return Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 9),
                                                              child: Icon(
                                                                  Icons.search,
                                                                  color: Colors
                                                                      .blueGrey),
                                                            ),
                                                            SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            Text(
                                                                'Search location / destination',
                                                                style: GoogleFonts
                                                                    .openSans()),
                                                          ],
                                                        );
                                                      },
                                                      openBuilder:
                                                          (context, action) {
                                                        return SearchPlace(
                                                          app: app,
                                                          onPlaceSelect:
                                                              () async {
                                                            setState(() {
                                                              _polylines = {};
                                                            });
                                                            if (Provider.of<DestinationMarkers>(context, listen: false)
                                                                            .places !=
                                                                        null &&
                                                                    Provider.of<PickupMarkers>(context, listen: false)
                                                                            .places !=
                                                                        null ||
                                                                Provider.of<UserData>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .pickuplocation !=
                                                                    null) {
                                                              await case1();
                                                            } else if (Provider.of<DestinationMarkers>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .places ==
                                                                    null &&
                                                                Provider.of<PickupMarkers>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .places !=
                                                                    null) {
                                                              printInfo(
                                                                  info:
                                                                      "CASE -2");
                                                              LatLng pickup = Provider.of<
                                                                          PickupMarkers>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .places;

                                                              if (pickup
                                                                  .toString()
                                                                  .isNotEmpty) {
                                                                setState(() {
                                                                  placeMarker =
                                                                      [];
                                                                  String pickupaddres = Provider.of<
                                                                              PickupMarkers>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .address;
                                                                  placeMarker.add(Marker(
                                                                      markerId:
                                                                          MarkerId(
                                                                              "Pick_up"),
                                                                      infoWindow: InfoWindow(
                                                                          title: pickupaddres
                                                                              .toString()),
                                                                      position:
                                                                          pickup));
                                                                });
                                                                CameraPosition
                                                                    cameraPosition =
                                                                    CameraPosition(
                                                                        target:
                                                                            pickup,
                                                                        zoom:
                                                                            18);
                                                                newmapcontroller
                                                                    .animateCamera(
                                                                  CameraUpdate
                                                                      .newCameraPosition(
                                                                          cameraPosition),
                                                                );
                                                              }
                                                            } else if (Provider.of<PickupMarkers>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .places ==
                                                                    null &&
                                                                Provider.of<DestinationMarkers>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .places !=
                                                                    null) {
                                                              printInfo(
                                                                  info:
                                                                      "CASE -3");
                                                              LatLng
                                                                  destination =
                                                                  Provider.of<DestinationMarkers>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .places;

                                                              if (destination
                                                                  .toString()
                                                                  .isNotEmpty) {
                                                                setState(() {
                                                                  placeMarker =
                                                                      [];
                                                                  String destinationaddres = Provider.of<
                                                                              DestinationMarkers>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .address;
                                                                  placeMarker.add(Marker(
                                                                      markerId:
                                                                          MarkerId(
                                                                              "Destination"),
                                                                      infoWindow: InfoWindow(
                                                                          title:
                                                                              destinationaddres),
                                                                      position:
                                                                          destination));
                                                                });
                                                                CameraPosition
                                                                    cameraPosition =
                                                                    CameraPosition(
                                                                        target:
                                                                            destination,
                                                                        zoom:
                                                                            18);
                                                                newmapcontroller
                                                                    .animateCamera(
                                                                  CameraUpdate
                                                                      .newCameraPosition(
                                                                          cameraPosition),
                                                                );
                                                              }
                                                            } else if (Provider.of<PickupMarkers>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .places ==
                                                                    null &&
                                                                Provider.of<DestinationMarkers>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .places ==
                                                                    null) {
                                                              print(
                                                                  "NO PLACE IS SELECTED ");
                                                            }
                                                          },
                                                        );
                                                      }),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      12),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .my_location,
                                                                    color: Colors
                                                                        .blueGrey,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                      "${Provider.of<PickupMarkers>(context, listen: false).places == null ? Provider.of<UserData>(context, listen: false).pickuplocation!.placeAddres.toString().substring(0, 26) : Provider.of<PickupMarkers>(context, listen: false).address.toString().substring(0, 26)}",
                                                                      style: GoogleFonts
                                                                          .openSans()),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 50,
                                                                      right:
                                                                          30),
                                                              child: SizedBox(
                                                                height: 20,
                                                                child: Divider(
                                                                  thickness: 1,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      12),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .location_on_rounded,
                                                                    color: Colors
                                                                            .red[
                                                                        900],
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                      "${Provider.of<DestinationMarkers>(context, listen: false).address.toString().length > 26 ? "${Provider.of<DestinationMarkers>(context, listen: false).address.toString().substring(0, 26)}" + "..." : "${Provider.of<DestinationMarkers>(context, listen: false).address.toString()}"} ",
                                                                      style: GoogleFonts
                                                                          .openSans()),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          3,
                                                                      vertical:
                                                                          1),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                              child: Text(
                                                                "${Provider.of<DirectionsProvider>(context, listen: false).time.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).time.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).time.toString().length)} Min",
                                                                style: GoogleFonts
                                                                    .openSans(
                                                                        color: Colors
                                                                            .white),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          10),
                                                              child: Container(
                                                                width: 50,
                                                                height: 1,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          3,
                                                                      vertical:
                                                                          1),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                              child: Text(
                                                                "${Provider.of<DirectionsProvider>(context, listen: false).distance.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length)} KM",
                                                                style: GoogleFonts
                                                                    .openSans(),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                ListTile(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedCar = "Cab-Mini";
                                                      print(
                                                          "Selected cab is Cab-Mini");
                                                    });
                                                  },
                                                  selectedTileColor:
                                                      Colors.grey,
                                                  leading: Image.asset(
                                                    'asset/images/mini_hatchback.jpg',
                                                    width: 70,
                                                    height: 75,
                                                  ),
                                                  selected:
                                                      selectedCar == "Cab-Mini"
                                                          ? true
                                                          : false,
                                                  title: Text(
                                                    'Cab-Mini',
                                                    style: GoogleFonts.openSans(
                                                        color: selectedCar ==
                                                                "Cab-Mini"
                                                            ? Colors
                                                                .blueGrey[600]
                                                            : Colors.black),
                                                  ),
                                                  trailing: Container(
                                                    child: Text(
                                                      (Provider.of<DirectionsProvider>(
                                                                              context,
                                                                              listen: false)
                                                                          .distance! *
                                                                      24 +
                                                                  60)
                                                              .ceil()
                                                              .toString() +
                                                          " \u{20B9}",
                                                      style: GoogleFonts.openSans(
                                                          color: selectedCar ==
                                                                  "Cab-Mini"
                                                              ? Colors
                                                                  .blueGrey[600]
                                                              : Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                ListTile(
                                                  focusColor: Colors.red,
                                                  selectedTileColor:
                                                      Colors.grey,
                                                  leading: Image.asset(
                                                    'asset/images/cab_.png',
                                                    width: 70,
                                                    height: 75,
                                                  ),
                                                  title: Text(
                                                    'Cab-UX',
                                                    style: GoogleFonts.openSans(
                                                        color: selectedCar ==
                                                                "Cab-UX"
                                                            ? Colors
                                                                .blueGrey[600]
                                                            : Colors.black),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      selectedCar = "Cab-UX";
                                                      print(
                                                          "Selected cab is Cab-UX");
                                                    });
                                                  },
                                                  selected:
                                                      selectedCar == "Cab-UX"
                                                          ? true
                                                          : false,
                                                  trailing: Container(
                                                    child: Text(
                                                      (Provider.of<DirectionsProvider>(
                                                                              context,
                                                                              listen: false)
                                                                          .distance! *
                                                                      35 +
                                                                  100)
                                                              .ceil()
                                                              .toString() +
                                                          " \u{20B9}",
                                                      style: GoogleFonts.openSans(
                                                          color: selectedCar ==
                                                                  "Cab-UX"
                                                              ? Colors
                                                                  .blueGrey[600]
                                                              : Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                ListTile(
                                                  focusColor: Colors.blueGrey,
                                                  hoverColor: Colors.blueGrey,
                                                  onTap: () {
                                                    setState(() {
                                                      selectedCar = "Cab-Delux";
                                                      print(
                                                          "Selected cab is Cab-Delux");
                                                    });
                                                  },
                                                  selected:
                                                      selectedCar == "Cab-Delux"
                                                          ? true
                                                          : false,
                                                  selectedTileColor:
                                                      Colors.black,
                                                  tileColor: Colors.white,
                                                  leading: Image.asset(
                                                    'asset/images/cab_delux_icon.png',
                                                    width: 70,
                                                    height: 75,
                                                  ),
                                                  title: Text(
                                                    'Cab-Delux',
                                                    style: GoogleFonts.openSans(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: selectedCar ==
                                                                "Cab-Delux"
                                                            ? Colors
                                                                .blueGrey[600]
                                                            : Colors.black),
                                                  ),
                                                  trailing: Container(
                                                    child: Text(
                                                      (Provider.of<DirectionsProvider>(
                                                                              context,
                                                                              listen: false)
                                                                          .distance! *
                                                                      42 +
                                                                  150)
                                                              .ceil()
                                                              .toString() +
                                                          " \u{20B9}",
                                                      style: GoogleFonts.openSans(
                                                          color: selectedCar ==
                                                                  "Cab-Delux"
                                                              ? Colors
                                                                  .blueGrey[600]
                                                              : Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 18),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      DropdownButton<String>(
                                                        value: selectedPayment,
                                                        icon: Icon(
                                                          LineIcons.wallet,
                                                          color: Colors.black,
                                                        ),
                                                        underline: SizedBox(
                                                          width: 0,
                                                          height: 1,
                                                          child: Container(
                                                              color: Colors
                                                                  .black87),
                                                        ),
                                                        iconSize: 24,
                                                        elevation: 0,
                                                        menuMaxHeight: 120,
                                                        itemHeight: 48,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                        dropdownColor:
                                                            Colors.grey[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            selectedPayment =
                                                                newValue!;
                                                          });
                                                        },
                                                        items: <String>[
                                                          'Cash',
                                                          'Razorpay'
                                                        ].map<
                                                            DropdownMenuItem<
                                                                String>>((String
                                                            value) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child: Container(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            2),
                                                                    child: Text(
                                                                        ''),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 9,
                                                                  ),
                                                                  Image.asset(
                                                                    "asset/images/$value.png",
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                  value ==
                                                                          "Cash"
                                                                      ? Text(
                                                                          "  \u{20B9}")
                                                                      : Text(
                                                                          "",
                                                                        ),
                                                                ],
                                                              ),
                                                              width: 80,
                                                              height: 25,
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                      ElevatedButton.icon(
                                                        onPressed:
                                                            getDriverDeatials,
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            24,
                                                                        vertical:
                                                                            8),
                                                                primary: Colors
                                                                    .black),
                                                        icon:
                                                            Icon(LineIcons.car),
                                                        label: Text(
                                                            "Search Cab",
                                                            style: GoogleFonts
                                                                .openSans()),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : !trip_details
                                      ? Container(
                                          height: 250.0,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(18.0),
                                              topRight: Radius.circular(18.0),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.3),
                                                blurRadius: 16.5,
                                                spreadRadius: 0.5,
                                                offset: Offset(0.7, 0.7),
                                              )
                                            ],
                                          ),
                                          child: ListView(
                                            controller: scrollController,
                                            children: [
                                              Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .horizontal_rule_rounded,
                                                      size: 32,
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                    Container(
                                                      height: 300,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      alignment:
                                                          Alignment.center,
                                                      child: l1.length == 0
                                                          ? Column(
                                                              children: [
                                                                Spacer(),
                                                                Text(
                                                                    "No Driver been found"),
                                                                SizedBox(
                                                                  height: 140,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  24,
                                                                              vertical:
                                                                                  8),
                                                                          primary:
                                                                              Colors.black),
                                                                      onPressed:
                                                                          getDriverDeatials,
                                                                      child: Text(
                                                                          "Search Again"),
                                                                    ),
                                                                    ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  32,
                                                                              vertical:
                                                                                  8),
                                                                          onPrimary: Colors
                                                                              .black,
                                                                          primary:
                                                                              Colors.white),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          cab_details =
                                                                              true;
                                                                          driver_details =
                                                                              false;
                                                                        });
                                                                      },
                                                                      child: Text(
                                                                          "Back"),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            )
                                                          : Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 250,
                                                                  child: ListView
                                                                      .builder(
                                                                          itemCount: l1
                                                                              .length,
                                                                          itemBuilder:
                                                                              (BuildContext context, int index) {
                                                                            return Material(
                                                                              color: Colors.white,
                                                                              child: InkWell(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                splashColor: Colors.blueGrey[100],
                                                                                onTap: () async {
                                                                                  user_trip_charge = "${selectedCar == "Cab-Mini" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 24 + 60).ceil().toString())}" : selectedCar == "Cab-UX" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 35 + 100).ceil().toString())}" : selectedCar == "Cab-Delux" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 42 + 150).ceil().toString())}" : ""}";
                                                                                  String? usertoken = await FirebaseMessaging.instance.getToken();
                                                                                  String pickup = Provider.of<PickupMarkers>(context, listen: false).places == null ? Provider.of<UserData>(context, listen: false).pickuplocation!.placeAddres.toString().substring(0, 26) : Provider.of<PickupMarkers>(context, listen: false).address.toString().substring(0, 26);
                                                                                  String destination = Provider.of<DestinationMarkers>(context, listen: false).address.toString().substring(0, 26);
                                                                                  String travel_time = Provider.of<DirectionsProvider>(context, listen: false).time.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).time.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).time.toString().length);

                                                                                  Position userLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                                                                                  String travel_distance = Provider.of<DirectionsProvider>(context, listen: false).distance.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length);
                                                                                  user_email = Provider.of<AccountProvider>(context, listen: false).userAccount.Email;
                                                                                  user_phone = Provider.of<AccountProvider>(context, listen: false).userAccount.Ph;
                                                                                  Msg().sendRidereq(
                                                                                    userLocation,
                                                                                    l1[index][3].toString(),
                                                                                    Provider.of<AccountProvider>(context, listen: false).userAccount.Uid,
                                                                                    Provider.of<AccountProvider>(context, listen: false).userAccount.Username,
                                                                                    Provider.of<PickupMarkers>(context, listen: false).address == null ? Provider.of<UserData>(context, listen: false).pickuplocation!.placeAddres : Provider.of<PickupMarkers>(context, listen: false).address,
                                                                                    Provider.of<DestinationMarkers>(context, listen: false).address,
                                                                                    usertoken!,
                                                                                    travel_distance,
                                                                                    travel_time,
                                                                                    user_phone,
                                                                                    pickup_lat,
                                                                                    pickup_long,
                                                                                    destination_lat,
                                                                                    destination_long,
                                                                                    user_trip_charge,
                                                                                    selectedCar,
                                                                                    selectedPayment,
                                                                                    Provider.of<AccountProvider>(context, listen: false).userAccount.rating,
                                                                                    user_email,
                                                                                  );
                                                                                  showDialog(
                                                                                      context: context,
                                                                                      barrierDismissible: false,
                                                                                      builder: (context) {
                                                                                        timer = Timer(Duration(seconds: 201), () {
                                                                                          while (Navigator.of(context, rootNavigator: true).canPop()) {
                                                                                            Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                                          }
                                                                                        });

                                                                                        return AlertDialog(
                                                                                          content: StreamBuilder(
                                                                                              initialData: 0,
                                                                                              stream: Stream.periodic(Duration(seconds: 1), (time) {
                                                                                                return time;
                                                                                              }),
                                                                                              builder: (builder, ctx) {
                                                                                                return SingleChildScrollView(
                                                                                                  child: Container(
                                                                                                    color: Colors.white,
                                                                                                    padding: EdgeInsets.all(4),
                                                                                                    width: MediaQuery.of(context).size.width * 0.75,
                                                                                                    height: min(
                                                                                                      350,
                                                                                                      MediaQuery.of(context).size.height * 0.5,
                                                                                                    ),
                                                                                                    child: Column(
                                                                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      children: [
                                                                                                        LinearProgressIndicator(
                                                                                                          value: (double.tryParse(ctx.data.toString())! / 201),
                                                                                                          backgroundColor: Colors.grey.shade400,
                                                                                                          valueColor: AlwaysStoppedAnimation(Colors.grey.shade700),
                                                                                                        ),
                                                                                                        Row(
                                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                                          children: [
                                                                                                            CircularProfileAvatar(
                                                                                                              l1[index][0].toString(),
                                                                                                              imageFit: BoxFit.cover,
                                                                                                              radius: 45,
                                                                                                              cacheImage: true,
                                                                                                              initialsText: Text(l1[index][2].toString().substring(0, 1)),
                                                                                                            ),
                                                                                                            SizedBox(
                                                                                                              width: 10,
                                                                                                            ),
                                                                                                            Column(
                                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  l1[index][1],
                                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                                  style: TextStyle(color: Colors.grey.shade800, fontSize: 18, fontWeight: FontWeight.w600),
                                                                                                                ),
                                                                                                                Text(
                                                                                                                  "$travel_distance Km | $travel_time Min",
                                                                                                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w300),
                                                                                                                ),
                                                                                                              ],
                                                                                                            )
                                                                                                          ],
                                                                                                        ),
                                                                                                        Text(
                                                                                                          "Pickup",
                                                                                                          textAlign: TextAlign.center,
                                                                                                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                                                                                                        ),
                                                                                                        SingleChildScrollView(
                                                                                                          scrollDirection: Axis.horizontal,
                                                                                                          child: Text(
                                                                                                            pickup,
                                                                                                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                                                                                          ),
                                                                                                        ),
                                                                                                        Text(
                                                                                                          "Destination",
                                                                                                          textAlign: TextAlign.center,
                                                                                                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                                                                                                        ),
                                                                                                        SingleChildScrollView(
                                                                                                          scrollDirection: Axis.horizontal,
                                                                                                          child: Text(
                                                                                                            destination,
                                                                                                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                                                                                          ),
                                                                                                        ),
                                                                                                        SizedBox(
                                                                                                          height: 4,
                                                                                                        ),
                                                                                                        SlideAction(
                                                                                                          submittedIcon: Icon(
                                                                                                            Iconsax.close_circle4,
                                                                                                            size: 15,
                                                                                                            color: Colors.red.shade700,
                                                                                                          ),
                                                                                                          text: "Slide to cancel",
                                                                                                          textStyle: TextStyle(color: Colors.grey.shade400),
                                                                                                          sliderButtonIconPadding: 9,
                                                                                                          height: 40,
                                                                                                          sliderButtonIconSize: 20,
                                                                                                          reversed: true,
                                                                                                          sliderButtonIcon: Icon(
                                                                                                            Iconsax.close_circle4,
                                                                                                            size: 15,
                                                                                                            color: Colors.white,
                                                                                                          ),
                                                                                                          onSubmit: () {
                                                                                                            Future.delayed(Duration(seconds: 1), () {
                                                                                                              Msg().sendRideCancelReq(l1[index][3].toString());
                                                                                                              while (Navigator.of(context, rootNavigator: true).canPop()) {
                                                                                                                Navigator.of(context, rootNavigator: true).pop('dialog');
                                                                                                              }
                                                                                                            });
                                                                                                          },
                                                                                                          innerColor: Colors.red.shade600,
                                                                                                          outerColor: Colors.white,
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                );
                                                                                              }),
                                                                                        );
                                                                                      });
                                                                                },
                                                                                child: Container(
                                                                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          ClipRRect(
                                                                                            borderRadius: BorderRadius.circular(25),
                                                                                            child: Image.network(
                                                                                              l1[index][0],
                                                                                              width: 50,
                                                                                              height: 50,
                                                                                              fit: BoxFit.cover,
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 10,
                                                                                          ),
                                                                                          Text(
                                                                                            l1[index][1],
                                                                                            textAlign: TextAlign.left,
                                                                                            style: GoogleFonts.dmSans(fontSize: 17),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      Container(
                                                                                        width: 50,
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            Icon(
                                                                                              LineIcons.starAlt,
                                                                                              color: Colors.amber,
                                                                                            ),
                                                                                            Text(
                                                                                              "${l1[index][2]}",
                                                                                              textAlign: TextAlign.left,
                                                                                              style: GoogleFonts.dmSans(
                                                                                                fontSize: 15,
                                                                                              ),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    TextButton
                                                                        .icon(
                                                                      style: TextButton
                                                                          .styleFrom(
                                                                        padding: EdgeInsets.symmetric(
                                                                            vertical:
                                                                                8,
                                                                            horizontal:
                                                                                25),
                                                                        primary:
                                                                            Colors.white,
                                                                        backgroundColor:
                                                                            Colors.black,
                                                                      ),
                                                                      onPressed:
                                                                          getDriverDeatials,
                                                                      icon: Icon(
                                                                          Icons
                                                                              .refresh_outlined),
                                                                      label: Text(
                                                                          "Refresh"),
                                                                    ),
                                                                    ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  32,
                                                                              vertical:
                                                                                  8),
                                                                          onPrimary: Colors
                                                                              .black,
                                                                          primary:
                                                                              Colors.white),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          cab_details =
                                                                              true;
                                                                          driver_details =
                                                                              false;
                                                                        });
                                                                      },
                                                                      child: Text(
                                                                          "Back"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                      // Padding(
                                                      //   padding:
                                                      //       const EdgeInsets.symmetric(
                                                      //           horizontal: 18),
                                                      //   child: Row(
                                                      //     mainAxisAlignment:
                                                      //         MainAxisAlignment
                                                      //             .spaceBetween,
                                                      //     children: [
                                                      //       DropdownButton<String>(
                                                      //         value: selectedPayment,
                                                      //         icon: Icon(
                                                      //           LineIcons.wallet,
                                                      //           color: Colors.black,
                                                      //         ),
                                                      //         underline: SizedBox(
                                                      //           width: 0,
                                                      //           height: 1,
                                                      //           child: Container(
                                                      //               color:
                                                      //                   Colors.black87),
                                                      //         ),
                                                      //         iconSize: 24,
                                                      //         elevation: 0,
                                                      //         menuMaxHeight: 120,
                                                      //         itemHeight: 48,
                                                      //         style: const TextStyle(
                                                      //             color: Colors.black),
                                                      //         dropdownColor:
                                                      //             Colors.grey[100],
                                                      //         borderRadius:
                                                      //             BorderRadius.circular(
                                                      //                 10),
                                                      //         onChanged:
                                                      //             (String? newValue) {
                                                      //           setState(() {
                                                      //             selectedPayment =
                                                      //                 newValue!;
                                                      //           });
                                                      //         },
                                                      //         items: <String>[
                                                      //           'Cash',
                                                      //           'Razorpay'
                                                      //         ].map<
                                                      //                 DropdownMenuItem<
                                                      //                     String>>(
                                                      //             (String value) {
                                                      //           return DropdownMenuItem<
                                                      //               String>(
                                                      //             value: value,
                                                      //             child: Container(
                                                      //               child: Row(
                                                      //                 mainAxisAlignment:
                                                      //                     MainAxisAlignment
                                                      //                         .start,
                                                      //                 children: [
                                                      //                   Padding(
                                                      //                     padding:
                                                      //                         const EdgeInsets
                                                      //                                 .only(
                                                      //                             bottom:
                                                      //                                 2),
                                                      //                     child: Text(''),
                                                      //                   ),
                                                      //                   SizedBox(
                                                      //                     width: 9,
                                                      //                   ),
                                                      //                   Image.asset(
                                                      //                     "asset/images/$value.png",
                                                      //                     fit: BoxFit
                                                      //                         .cover,
                                                      //                   ),
                                                      //                   value == "Cash"
                                                      //                       ? Text(
                                                      //                           "  \u{20B9}")
                                                      //                       : Text(
                                                      //                           "",
                                                      //                         ),
                                                      //                 ],
                                                      //               ),
                                                      //               width: 80,
                                                      //               height: 25,
                                                      //             ),
                                                      //           );
                                                      //         }).toList(),
                                                      //       ),
                                                      //       ElevatedButton.icon(
                                                      //         onPressed:
                                                      //             getDriverDeatials,
                                                      //         style: ElevatedButton
                                                      //             .styleFrom(
                                                      //                 padding: EdgeInsets
                                                      //                     .symmetric(
                                                      //                         horizontal:
                                                      //                             24,
                                                      //                         vertical:
                                                      //                             8),
                                                      //                 primary:
                                                      //                     Colors.black),
                                                      //         icon: Icon(LineIcons.car),
                                                      //         label: Text("Search Cab"),
                                                      //       ),
                                                      //     ],
                                                      //   ),
                                                      // )
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : !reaching_destination
                                          ? Container(
                                              height: 250.0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24.0,
                                                      vertical: 10.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(18.0),
                                                  topRight:
                                                      Radius.circular(18.0),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.3),
                                                    blurRadius: 16.5,
                                                    spreadRadius: 0.5,
                                                    offset: Offset(0.7, 0.7),
                                                  )
                                                ],
                                              ),
                                              child: ListView(
                                                controller: scrollController,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .arrow_drop_up_rounded,
                                                            size: 30,
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                            child: Image.network(
                                                                "${Provider.of<DriverProvider>(context, listen: false).driver.imageurl}",
                                                                width: 70,
                                                                height: 70,
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  "${Provider.of<DriverProvider>(context, listen: false).driver.username}",
                                                                  style: GoogleFonts.roboto(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600)),
                                                              Text(
                                                                  "${Provider.of<DriverProvider>(context, listen: false).driver.phone}",
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black45))
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                LineIcons
                                                                    .starAlt,
                                                                color: Colors
                                                                    .amber,
                                                              ),
                                                              Text(
                                                                "  ${Provider.of<DriverProvider>(context, listen: false).driver.rating}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    GoogleFonts
                                                                        .dmSans(
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Image.network(
                                                              '${Provider.of<DriverProvider>(context, listen: false).driver.cabimage}',
                                                              width: 140,
                                                              height: 90,
                                                              fit:
                                                                  BoxFit.cover),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${Provider.of<DriverProvider>(context, listen: false).driver.cab_model}',
                                                                style: GoogleFonts.roboto(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                              Text(
                                                                '${Provider.of<DriverProvider>(context, listen: false).driver.cab_number}',
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 12,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              FaIcon(
                                                                  Iconsax.map5),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                  "    ${Provider.of<DirectionsProvider>(context, listen: false).distance.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length)} " +
                                                                      " KM",
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black45))
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(Iconsax
                                                                  .clock5),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                  "  ${Provider.of<DirectionsProvider>(context, listen: false).time.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).time.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).time.toString().length)}" +
                                                                      " Min",
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black45))
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(' \u{20B9}',
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .black)),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                  "${selectedCar == "Cab-Mini" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 24 + 60).ceil().toString())}" : selectedCar == "Cab-UX" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 35 + 100).ceil().toString())}" : selectedCar == "Cab-Delux" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 42 + 150).ceil().toString())}" : ""}" +
                                                                      " Rupee",
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black45))
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 16,
                                                      ),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons
                                                                .my_location_rounded),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "  ${Provider.of<PickupMarkers>(context, listen: false).address == null ? Provider.of<UserData>(context, listen: false).pickuplocation!.placeAddres : Provider.of<PickupMarkers>(context, listen: false).address}",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black54),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 16,
                                                      ),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons
                                                                .location_on_rounded),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              " ${Provider.of<DestinationMarkers>(context, listen: false).address}",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black54),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          TextButton.icon(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    primary: Colors
                                                                        .black,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .symmetric(
                                                                      vertical:
                                                                          8,
                                                                      horizontal:
                                                                          20,
                                                                    )),
                                                            onPressed: () {
                                                              launch(
                                                                  "tel://${Provider.of<DriverProvider>(context, listen: false).driver.phone}");
                                                            },
                                                            icon: Icon(
                                                              Icons.phone,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            label: Text(" Call",
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white)),
                                                          ),
                                                          TextButton.icon(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    primary: Colors
                                                                        .black,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .symmetric(
                                                                      vertical:
                                                                          8,
                                                                      horizontal:
                                                                          20,
                                                                    )),
                                                            onPressed:
                                                                () async {
                                                              SharedPreferences
                                                                  prefs =
                                                                  await SharedPreferences
                                                                      .getInstance();

                                                              var response =
                                                                  prefs.setBool(
                                                                      "isdriverpickup",
                                                                      false);
                                                              setState(() {
                                                                placeMarker.removeWhere((element) =>
                                                                    element
                                                                        .markerId
                                                                        .value ==
                                                                    "Driver_location");

                                                                cab_details =
                                                                    true;
                                                                driver_details =
                                                                    false;
                                                                trip_details =
                                                                    false;
                                                                try {
                                                                  driver_location_sub
                                                                      .cancel();
                                                                } catch (e) {}
                                                              });
                                                              Msg()
                                                                  .sendCancelTrip(Provider.of<
                                                                              DriverProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .driver
                                                                      .driver_token)
                                                                  .then(
                                                                      (value) {
                                                                setState(() {
                                                                  placeMarker.removeWhere((element) =>
                                                                      element
                                                                          .markerId
                                                                          .value ==
                                                                      "Driver_location");

                                                                  cab_details =
                                                                      true;
                                                                  driver_details =
                                                                      false;
                                                                  trip_details =
                                                                      false;
                                                                  try {
                                                                    driver_location_sub
                                                                        .cancel();
                                                                  } catch (e) {}
                                                                });
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .cancel_outlined,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            label: Text(
                                                                " Cancel Ride",
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white)),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container(
                                              height: 250.0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24.0,
                                                      vertical: 10.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(18.0),
                                                  topRight:
                                                      Radius.circular(18.0),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.3),
                                                    blurRadius: 16.5,
                                                    spreadRadius: 0.5,
                                                    offset: Offset(0.7, 0.7),
                                                  )
                                                ],
                                              ),
                                              child: ListView(
                                                controller: scrollController,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .arrow_drop_up_rounded,
                                                            size: 30,
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0),
                                                            child: Image.network(
                                                                "${Provider.of<DriverProvider>(context, listen: false).driver.imageurl}",
                                                                width: 70,
                                                                height: 70,
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  "${Provider.of<DriverProvider>(context, listen: false).driver.username}",
                                                                  style: GoogleFonts.roboto(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600)),
                                                              Text(
                                                                  "${Provider.of<DriverProvider>(context, listen: false).driver.phone}",
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .black45))
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                LineIcons
                                                                    .starAlt,
                                                                color: Colors
                                                                    .amber,
                                                              ),
                                                              Text(
                                                                "  ${Provider.of<DriverProvider>(context, listen: false).driver.rating}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    GoogleFonts
                                                                        .dmSans(
                                                                  fontSize: 15,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Image.network(
                                                              '${Provider.of<DriverProvider>(context, listen: false).driver.cabimage}',
                                                              width: 140,
                                                              height: 90,
                                                              fit:
                                                                  BoxFit.cover),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${Provider.of<DriverProvider>(context, listen: false).driver.cab_model}',
                                                                style: GoogleFonts.roboto(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                              Text(
                                                                '${Provider.of<DriverProvider>(context, listen: false).driver.cab_number}',
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black54,
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 12,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              FaIcon(
                                                                  Iconsax.map5),
                                                              Text(
                                                                  "      ${Provider.of<DirectionsProvider>(context, listen: false).distance.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length)} " +
                                                                      " KM",
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black45))
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Icon(Iconsax
                                                                  .clock5),
                                                              Text(
                                                                  "     ${Provider.of<DirectionsProvider>(context, listen: false).time.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).time.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).time.toString().length)}" +
                                                                      " Min",
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black45))
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(' \u{20B9}',
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .black)),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                  "${selectedCar == "Cab-Mini" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 24 + 60).ceil().toString())}" : selectedCar == "Cab-UX" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 35 + 100).ceil().toString())}" : selectedCar == "Cab-Delux" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 42 + 150).ceil().toString())}" : ""}" +
                                                                      " Rupee",
                                                                  style: GoogleFonts.openSans(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black45))
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 16,
                                                      ),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons
                                                                .my_location_rounded),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "  ${Provider.of<PickupMarkers>(context, listen: false).address == null ? Provider.of<UserData>(context, listen: false).pickuplocation!.placeAddres : Provider.of<PickupMarkers>(context, listen: false).address}",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black54),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 16,
                                                      ),
                                                      SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons
                                                                .location_on_rounded),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              "${Provider.of<DestinationMarkers>(context, listen: false).address}",
                                                              style: GoogleFonts
                                                                  .openSans(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black54),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          TextButton.icon(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    primary: Colors
                                                                        .black,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .symmetric(
                                                                      vertical:
                                                                          8,
                                                                      horizontal:
                                                                          20,
                                                                    )),
                                                            onPressed: () {},
                                                            icon: Icon(
                                                              Icons
                                                                  .help_center_rounded,
                                                              size: 20,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            label: Text(
                                                                "Emergency",
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white)),
                                                          ),
                                                          // TextButton.icon(
                                                          //   icon: LineIcon(
                                                          //       LineIcons.car,
                                                          //       size: 20,
                                                          //       color: Colors
                                                          //           .white),
                                                          //   style: ElevatedButton
                                                          //       .styleFrom(
                                                          //           primary: Colors
                                                          //               .black,
                                                          //           padding:
                                                          //               EdgeInsets
                                                          //                   .symmetric(
                                                          //             vertical:
                                                          //                 8,
                                                          //             horizontal:
                                                          //                 20,
                                                          //           )),
                                                          //   onPressed:
                                                          //       () async {
                                                          //     SharedPreferences
                                                          //         prefs =
                                                          //         await SharedPreferences
                                                          //             .getInstance();

                                                          //     var response =
                                                          //         prefs.setBool(
                                                          //             "isdriverpickup",
                                                          //             false);
                                                          //     Msg()
                                                          //         .sendCancelTrip(Provider.of<
                                                          //                     DriverProvider>(
                                                          //                 context,
                                                          //                 listen:
                                                          //                     false)
                                                          //             .driver
                                                          //             .driver_token)
                                                          //         .then(
                                                          //             (value) {
                                                          //       setState(() {
                                                          //         placeMarker.removeWhere((element) =>
                                                          //             element
                                                          //                 .markerId
                                                          //                 .value ==
                                                          //             "Driver_location");

                                                          //         cab_details =
                                                          //             true;
                                                          //         driver_details =
                                                          //             false;
                                                          //         trip_details =
                                                          //             false;
                                                          //         try {
                                                          //           driver_location_sub
                                                          //               .cancel();
                                                          //         } catch (e) {}
                                                          //       });
                                                          //     });
                                                          //   },
                                                          //   label: Text("",
                                                          //       style: GoogleFonts
                                                          //           .montserrat(
                                                          //               fontSize:
                                                          //                   16,
                                                          //               color: Colors
                                                          //                   .white)),
                                                          // ),
                                                          TextButton.icon(
                                                            icon: LineIcon(
                                                                LineIcons.car,
                                                                size: 20,
                                                                color: Colors
                                                                    .white),
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    primary: Colors
                                                                        .black,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .symmetric(
                                                                      vertical:
                                                                          8,
                                                                      horizontal:
                                                                          20,
                                                                    )),
                                                            onPressed:
                                                                () async {
                                                              if (selectedPayment ==
                                                                  "Cash") {
                                                                Msg()
                                                                    .sendCashPayment(Provider.of<DriverProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .driver
                                                                        .driver_token)
                                                                    .then(
                                                                        (value) {
                                                                  showDialog(
                                                                      barrierDismissible:
                                                                          false,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (builder) {
                                                                        return ClassicGeneralDialogWidget(
                                                                          actions: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                                                              child: SingleChildScrollView(
                                                                                child: Column(
                                                                                  children: [
                                                                                    Text(
                                                                                      "Payment (Cash)",
                                                                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
                                                                                    ),
                                                                                    Image.asset('asset/images/cash_pay.png'),
                                                                                    Text(
                                                                                      "Total Amount: ${selectedCar == "Cab-Mini" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 24 + 60).ceil().toString())}" : selectedCar == "Cab-UX" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 35 + 100).ceil().toString())}" : selectedCar == "Cab-Delux" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 42 + 150).ceil().toString())}" : ""}" +
                                                                                          " Rupee",
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 10,
                                                                                    ),
                                                                                    AnimatedTextKit(
                                                                                      animatedTexts: [
                                                                                        ColorizeAnimatedText(
                                                                                          "Waiting for Driver's Confirmation",
                                                                                          textStyle: GoogleFonts.poppins(
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                          colors: [
                                                                                            Colors.grey.shade900,
                                                                                            Colors.grey.shade300,
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                      repeatForever: true,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      });
                                                                });
                                                              } else {
                                                                showDialog(
                                                                    barrierDismissible:
                                                                        false,
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (builder) {
                                                                      return ClassicGeneralDialogWidget(
                                                                        actions: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Text(
                                                                                  "Payment (Online)",
                                                                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
                                                                                ),
                                                                                Image.asset('asset/images/online_pay.png'),
                                                                                Text(
                                                                                  "Total Amount: ${selectedCar == "Cab-Mini" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 24 + 60).ceil().toString())}" : selectedCar == "Cab-UX" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 35 + 100).ceil().toString())}" : selectedCar == "Cab-Delux" ? "${((Provider.of<DirectionsProvider>(context, listen: false).distance! * 42 + 150).ceil().toString())}" : ""}" +
                                                                                      " Rupee",
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                TextButton.icon(
                                                                                  icon: LineIcon(LineIcons.moneyBill, size: 20, color: Colors.white),
                                                                                  style: ElevatedButton.styleFrom(
                                                                                      primary: Colors.black,
                                                                                      padding: EdgeInsets.symmetric(
                                                                                        vertical: 8,
                                                                                        horizontal: 20,
                                                                                      )),
                                                                                  onPressed: openCheckout,
                                                                                  label: Text("Pay with Razorypay", style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white)),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    });
                                                              }
                                                            },
                                                            label: Text(
                                                                "End Trip",
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .white)),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18.0),
                                  topRight: Radius.circular(18.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.3),
                                    blurRadius: 16.5,
                                    spreadRadius: 0.5,
                                  )
                                ],
                              ),
                              child: ListView(
                                controller: scrollController,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0, vertical: 18.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            "asset/images/no_internet.png"),
                                        Text(
                                          "No Internet Connection",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 19,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, .7),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: "Menu",
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                      icon: Icon(Iconsax.menu_1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
