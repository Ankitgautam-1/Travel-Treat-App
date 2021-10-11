import 'dart:async';
import 'dart:io';
import 'package:app/Data/DirectionProvider.dart';

import 'package:app/Data/pickuploc.dart';
import 'package:app/services/getDirections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:app/Data/accountProvider.dart';
import 'package:app/Data/destinationmarkers.dart';
import 'package:app/Data/image.dart';
import 'package:app/Data/userData.dart';
import 'package:app/models/userAccount.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:app/services/assistantmethod.dart';
import 'package:app/views/Welcome.dart';
import 'package:app/views/searchplace.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

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
  _MapsState({required this.app});
  var username, email, ph, image, provider, uid;
  final CameraPosition _initpostion = CameraPosition(
    target: LatLng(18.9217, 72.8332),
    zoom: 17.1414,
  );
  bool cab_details = false;
  List<Marker> placeMarker = [];
  late GoogleMapController newmapcontroller;
  Completer<GoogleMapController> mapcontroller = Completer();

  late Position currentPosition;
  List<LatLng> polylineCoordinates = [];

  Map<PolylineId, Polyline> polyline = {};
  PolylinePoints polylinePoints = PolylinePoints();
  // ignore: cancel_subscriptions
  StreamSubscription<Position>? positionStream;
  bool loadingplace = false;
  var geoLocator = Geolocator();
  List<LatLng>? poly = [];
  Set<Polyline> _polylines = {};
  late Position position;

  void track() async {
    positionStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
            .listen(
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

  void getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    dynamic res = await Geocoding().getAddress(position, context);
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
            markerId: MarkerId(curloc.toString()),
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
    await prefs.remove('Image');
    try {
      await GoogleSignIn().signOut();
    } catch (e) {}
    await FirebaseAuth.instance.signOut();
    if (Provider.of<ImageData>(context, listen: false).image != null) {
      Provider.of<ImageData>(context, listen: false).updateimage(null);
    }
    UserAccount userAccount = UserAccount(
        Email: "", Image: "", Ph: "", Uid: "", Username: "", emph: "");
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

  @override
  void initState() {
    getData();
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

  Future<void> case1() async {
    print("CASE -1 HERE");
    LatLng pickup = Provider.of<PickupMarkers>(context, listen: false).places !=
            null
        ? Provider.of<PickupMarkers>(context, listen: false).places
        : LatLng(
            Provider.of<UserData>(context, listen: false).pickuplocation!.lat,
            Provider.of<UserData>(context, listen: false).pickuplocation!.lng);
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
    setState(() {
      placeMarker = [];
      placeMarker.add(
        Marker(
          markerId: MarkerId(pickup.toString()),
          infoWindow: InfoWindow(title: pickupaddress),
          position: pickup,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      placeMarker.add(
        Marker(
          markerId: MarkerId(destination.toString()),
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
      if (await directions.getDirections() == null) {}
      print("the value is poly:$poly ");
    } catch (e) {
      print("errors $e");
    }
    setState(() {
      _polylines = {
        Polyline(
            width: 3,
            polylineId: PolylineId("1"),
            color: Colors.black,
            jointType: JointType.bevel,
            points: Provider.of<DirectionsProvider>(context, listen: false)
                .cordinates_collections!)
      };

      // CameraPosition
      CameraPosition cameraPosition = CameraPosition(target: pickup, zoom: 18);
      newmapcontroller.animateCamera(
        CameraUpdate.newLatLngBounds(
            Provider.of<DirectionsProvider>(context, listen: false).bounds!,
            65.0),
      );
      cab_details = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('rebuilding the widget');
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height * 0.879,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.80,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      indoorViewEnabled: false,
                      minMaxZoomPreference: MinMaxZoomPreference.unbounded,
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
                        mapcontroller.complete(controller);
                        newmapcontroller = controller;
                        print("Locating ");
                        locatePosition();
                      },
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 15, left: 20),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: Color.fromRGBO(255, 255, 255, .7),
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: IconButton(
                  //       tooltip: "Menu",
                  //       onPressed: () {
                  //         _scaffoldKey.currentState!.openDrawer();
                  //       },
                  //       icon: Icon(Icons.menu),
                  //     ),  ///!this is moved to dashboard
                  //   ),
                  // ),
                  cab_details
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
                                    cab_details = false;
                                    Provider.of<DestinationMarkers>(context,
                                            listen: false)
                                        .updateDestinationMarkers(null, null);
                                    Provider.of<PickupMarkers>(context,
                                            listen: false)
                                        .updatePickupMarkers(null, null);
                                    Provider.of<UserData>(context,
                                            listen: false)
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
                                  },
                                );
                              },
                              icon: Icon(Icons.cancel_outlined),
                            ),
                          ),
                        )
                      : Container(),
                  DraggableScrollableSheet(
                    initialChildSize: 0.3,
                    minChildSize: 0.138,
                    maxChildSize: 0.4,
                    builder: (BuildContext buildContext,
                        ScrollController scrollController) {
                      return !cab_details
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
                                          child: InkWell(
                                            onTap: () {
                                              Get.to(
                                                SearchPlace(
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
                                                      print("CASE -1");
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
                                                      print("CASE -2");
                                                      LatLng pickup = Provider
                                                              .of<PickupMarkers>(
                                                                  context,
                                                                  listen: false)
                                                          .places;

                                                      if (pickup
                                                          .toString()
                                                          .isNotEmpty) {
                                                        setState(() {
                                                          placeMarker = [];
                                                          String pickupaddres =
                                                              Provider.of<PickupMarkers>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .address;
                                                          placeMarker.add(Marker(
                                                              markerId: MarkerId(
                                                                  pickup
                                                                      .toString()),
                                                              infoWindow: InfoWindow(
                                                                  title: pickupaddres
                                                                      .toString()),
                                                              position:
                                                                  pickup));
                                                        });
                                                        CameraPosition
                                                            cameraPosition =
                                                            CameraPosition(
                                                                target: pickup,
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
                                                      print("CASE -3");
                                                      LatLng destination = Provider
                                                              .of<DestinationMarkers>(
                                                                  context,
                                                                  listen: false)
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
                                                              markerId: MarkerId(
                                                                  destination
                                                                      .toString()),
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
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 9),
                                                  child: Icon(Icons.search,
                                                      color: Colors.blueGrey),
                                                ),
                                                SizedBox(
                                                  width: 10.0,
                                                ),
                                                Text(
                                                    'Search location / destination'),
                                              ],
                                            ),
                                          ),
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
                                                                  height: 25,
                                                                  width: 25,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        3,
                                                                  ),
                                                                ),
                                                              )
                                                            : Text(
                                                                Provider.of<UserData>(context, listen: false)
                                                                            .pickuplocation ==
                                                                        null
                                                                    ? "Current Location"
                                                                    : Provider.of<UserData>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .pickuplocation!
                                                                        .placeAddres,
                                                                softWrap: true,
                                                              ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            loadingplace = true;
                                                          });
                                                          getCurrentLoc();
                                                        },
                                                        icon: Icon(Icons.add),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4.0,
                                                ),
                                                Text(
                                                  "Your current address (estimated)",
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 12.0,
                                                  ),
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
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Row(
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
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Add Home'),
                                                SizedBox(
                                                  height: 4.0,
                                                ),
                                                Text(
                                                  "Your Home address",
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          height: 1.0,
                                          color: Colors.black,
                                          thickness: 1.0,
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.work,
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
                                                Text('Add work'),
                                                SizedBox(
                                                  height: 4.0,
                                                ),
                                                Text(
                                                  "Your office address",
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
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
                                                BorderRadius.circular(12.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.4),
                                                blurRadius: 6.0,
                                                spreadRadius: 0.5,
                                                offset: Offset(0.7, 0.7),
                                              )
                                            ],
                                          ),
                                          child: InkWell(
                                            focusColor: Color.fromRGBO(
                                                146, 182, 240, 1),
                                            onTap: () {
                                              Get.to(
                                                SearchPlace(
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
                                                      LatLng pickup = Provider
                                                              .of<PickupMarkers>(
                                                                  context,
                                                                  listen: false)
                                                          .places;

                                                      if (pickup
                                                          .toString()
                                                          .isNotEmpty) {
                                                        setState(() {
                                                          placeMarker = [];
                                                          String pickupaddres =
                                                              Provider.of<PickupMarkers>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .address;
                                                          placeMarker.add(Marker(
                                                              markerId: MarkerId(
                                                                  pickup
                                                                      .toString()),
                                                              infoWindow: InfoWindow(
                                                                  title: pickupaddres
                                                                      .toString()),
                                                              position:
                                                                  pickup));
                                                        });
                                                        CameraPosition
                                                            cameraPosition =
                                                            CameraPosition(
                                                                target: pickup,
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
                                                      LatLng destination = Provider
                                                              .of<DestinationMarkers>(
                                                                  context,
                                                                  listen: false)
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
                                                              markerId: MarkerId(
                                                                  destination
                                                                      .toString()),
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
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 9),
                                                  child: Icon(Icons.search,
                                                      color: Colors.blueGrey),
                                                ),
                                                SizedBox(
                                                  width: 10.0,
                                                ),
                                                Text(
                                                    'Search location / destination'),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 300,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.my_location,
                                                          color: Colors.grey,
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                            "${Provider.of<PickupMarkers>(context, listen: false).places == null ? Provider.of<UserData>(context, listen: false).pickuplocation!.placeAddres.toString().substring(0, 31) : Provider.of<PickupMarkers>(context, listen: false).address.toString().substring(0, 31)}"),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 50,
                                                            right: 30),
                                                    child: SizedBox(
                                                      height: 20,
                                                      child: Divider(
                                                        thickness: 1,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_on_rounded,
                                                          color:
                                                              Colors.red[900],
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                            "${Provider.of<DestinationMarkers>(context, listen: false).address.toString().substring(0, 30)}"),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 60,
                                              height: 60,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "${Provider.of<DirectionsProvider>(context, listen: false).time.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).time.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).time.toString().length)} Min"),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                      "${Provider.of<DirectionsProvider>(context, listen: false).distance.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length)} KM"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
