import 'dart:async';
import 'dart:io';
import 'package:app/Data/pickuploc.dart';
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
import 'package:app/models/userAddress.dart';
import 'package:app/services/assistantmethod.dart';
import 'package:app/views/Welcome.dart';
import 'package:app/views/searchplace.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

// ignore: must_be_immutable
//
//

// ignore: must_be_immutable
class Maps extends StatefulWidget {
  FirebaseApp app;
  Maps({required this.app});
  @override
  _MapsState createState() => _MapsState(app: app);
}

class _MapsState extends State<Maps> {
  FirebaseApp app;
  _MapsState({required this.app});
  var username, email, ph, image, provider, uid;
  final CameraPosition _initpostion = CameraPosition(
    target: LatLng(18.9217, 72.8332),
    zoom: 17.1414,
  );

  List<Marker> placeMarker = [];
  late GoogleMapController newmapcontroller;
  Completer<GoogleMapController> mapcontroller = Completer();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late Position currentPosition;
  StreamSubscription<Position>? positionStream;
  bool loadingplace = false;
  var geoLocator = Geolocator();

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

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 18);
    print("latlng :-$latLngPosition");
    newmapcontroller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
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
        CameraPosition cameraPosition =
            CameraPosition(target: curloc, zoom: 19);
        newmapcontroller.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
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
    UserAccount userAccount =
        UserAccount(Email: "", Image: "", Ph: "", Uid: "", Username: "");
    Provider.of<AccountProvider>(context, listen: false)
        .updateuseraccount(userAccount);
    Provider.of<UserData>(context, listen: false)
        .updatepickuplocation(UserAddress(placeAddres: "", lat: 0, lng: 0));
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height * 0.958,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.88,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      indoorViewEnabled: true,
                      minMaxZoomPreference: MinMaxZoomPreference.unbounded,
                      initialCameraPosition: _initpostion,
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                      zoomControlsEnabled: true,
                      mapToolbarEnabled: true,
                      compassEnabled: false,
                      markers: Set.from(placeMarker),
                      trafficEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        mapcontroller.complete(controller);
                        newmapcontroller = controller;
                        print("Locating ");
                        locatePosition();
                      },
                    ),
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
                        icon: Icon(Icons.menu),
                      ),
                    ),
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.3,
                    minChildSize: 0.12,
                    maxChildSize: 0.4,
                    builder: (BuildContext buildContext,
                        ScrollController scrollController) {
                      return Container(
                        height: 250.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 16.5,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Icon(Icons.keyboard_arrow_up_sharp),
                                  ),
                                  Text(
                                    "Hi there,",
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                  Text(
                                    "Where to",
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Container(
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black54,
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
                                            onPlaceSelect: () {
                                              if (Provider.of<DestinationMarkers>(
                                                              context,
                                                              listen: false)
                                                          .places !=
                                                      null &&
                                                  Provider.of<PickupMarkers>(
                                                              context,
                                                              listen: false)
                                                          .places !=
                                                      null) {
                                                print("CASE -1 HERE");
                                                LatLng pickup =
                                                    Provider.of<PickupMarkers>(
                                                            context,
                                                            listen: false)
                                                        .places;
                                                String pickupaddress =
                                                    Provider.of<PickupMarkers>(
                                                            context,
                                                            listen: false)
                                                        .address;

                                                LatLng destination = Provider
                                                        .of<DestinationMarkers>(
                                                            context,
                                                            listen: false)
                                                    .places;
                                                String destinationaddress =
                                                    Provider.of<PickupMarkers>(
                                                            context,
                                                            listen: false)
                                                        .address;
                                                setState(() {
                                                  placeMarker = [];
                                                  placeMarker.add(Marker(
                                                      markerId: MarkerId(
                                                          pickup.toString()),
                                                      infoWindow: InfoWindow(
                                                          title: pickupaddress),
                                                      position: pickup));
                                                  placeMarker.add(Marker(
                                                      markerId: MarkerId(
                                                          destination
                                                              .toString()),
                                                      infoWindow: InfoWindow(
                                                          title:
                                                              destinationaddress),
                                                      position: destination));
                                                });
                                              } else if (Provider.of<
                                                                  DestinationMarkers>(
                                                              context,
                                                              listen: false)
                                                          .places ==
                                                      null &&
                                                  Provider.of<PickupMarkers>(
                                                              context,
                                                              listen: false)
                                                          .places !=
                                                      null) {
                                                printInfo(info: "CASE -2");
                                                LatLng pickup =
                                                    Provider.of<PickupMarkers>(
                                                            context,
                                                            listen: false)
                                                        .places;

                                                if (pickup
                                                    .toString()
                                                    .isNotEmpty) {
                                                  setState(() {
                                                    placeMarker = [];
                                                    String pickupaddres = Provider
                                                            .of<PickupMarkers>(
                                                                context,
                                                                listen: false)
                                                        .address;
                                                    placeMarker.add(Marker(
                                                        markerId: MarkerId(
                                                            pickup.toString()),
                                                        infoWindow: InfoWindow(
                                                            title: pickupaddres
                                                                .toString()),
                                                        position: pickup));
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
                                                              listen: false)
                                                          .places ==
                                                      null &&
                                                  Provider.of<DestinationMarkers>(
                                                              context,
                                                              listen: false)
                                                          .places !=
                                                      null) {
                                                printInfo(info: "CASE -3");
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
                                                    String destinationaddres =
                                                        Provider.of<PickupMarkers>(
                                                                context,
                                                                listen: false)
                                                            .address;
                                                    placeMarker.add(Marker(
                                                        markerId: MarkerId(
                                                            destination
                                                                .toString()),
                                                        infoWindow: InfoWindow(
                                                            title:
                                                                destinationaddres),
                                                        position: destination));
                                                  });
                                                  CameraPosition
                                                      cameraPosition =
                                                      CameraPosition(
                                                          target: destination,
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
                                                              listen: false)
                                                          .places ==
                                                      null &&
                                                  Provider.of<DestinationMarkers>(
                                                              context,
                                                              listen: false)
                                                          .places ==
                                                      null) {
                                                print("NO PLACE IS SELECTED ");
                                              } else {
                                                print("still");
                                              }
                                            },
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 9),
                                            child: Icon(Icons.search,
                                                color: Colors.blueGrey),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Text('Search drop off location'),
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
                                                          child: Container(
                                                            height: 25,
                                                            width: 25,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 3,
                                                            ),
                                                          ),
                                                        )
                                                      : Text(
                                                          Provider.of<UserData>(
                                                                          context)
                                                                      .pickuplocation ==
                                                                  null
                                                              ? "Current Location"
                                                              : Provider.of<
                                                                          UserData>(
                                                                      context)
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
                      );
                    },
                  ),
                ],
              )),
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: [
                profile(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget profile() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.958,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: Provider.of<ImageData>(context, listen: false).image == null
                ? CircleAvatar(
                    backgroundColor: Colors.black26,
                    radius: 55,
                    backgroundImage: FileImage(File(
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .Image!)),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.black26,
                    radius: 55,
                    backgroundImage: FileImage(
                        Provider.of<ImageData>(context, listen: false).image!),
                  ),
          ),
          SizedBox(
            height: 35,
          ),
          Text(
            Provider.of<AccountProvider>(context).userAccount.Username,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            Provider.of<AccountProvider>(context).userAccount.Email,
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(
              Icons.home_rounded,
            ),
            title: Text('Home'),
            selected: true,
            onTap: () {
              print("Home visited");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.account_box,
            ),
            title: Text('Account'),
            selected: false,
            onTap: () {
              print("accont visited");
            },
          ),
          ListTile(
            leading: FaIcon(FontAwesomeIcons.car),
            title: Text('My trips'),
            selected: false,
            onTap: () {
              print("Trip visited");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
            ),
            title: Text('Settings'),
            selected: false,
            onTap: () {
              print("settings visited");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout_rounded,
            ),
            title: Text('Log Out'),
            selected: false,
            onTap: () {
              logoutgoogleuser();
            },
          ),
        ],
      ),
    );
  }
}
