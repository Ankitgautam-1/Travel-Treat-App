import 'dart:async';
import 'dart:io';
import 'package:app/Data/DirectionProvider.dart';

import 'package:app/Data/pickuploc.dart';
import 'package:app/Utils/Utils.dart';
import 'package:app/models/driverDetails.dart';
import 'package:app/services/getDirections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart' as loc;
import 'package:map_picker/map_picker.dart';
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
  List l1 = [];
  List<Marker> placeMarker = [];
  late GoogleMapController newmapcontroller;
  LatLng? curloc;
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
  List<LatLng>? poly = [];
  Set<Polyline> _polylines = {};
  late Position position;
  String selectedCar = "Cab-UX";
  String selectedPayment = "Cash";
  var textController = TextEditingController();
  bool ismapcontrollercreated = false;
  MapPickerController mapPickerController = MapPickerController();
  bool usingmappin = false;
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
            markerId: MarkerId(curloc.toString()),
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

  void getDriverDeatials() async {
    if (getloc != null) {
      getloc!.cancel();
    }
    var collectionReference = _firestore.collection('Locations');
    var geoRef = geo.collection(collectionRef: collectionReference);
    Userloc = Geolocator.getPositionStream();
    GeoFirePoint current =
        geo.point(latitude: position.latitude, longitude: position.longitude);

    Stream<List<DocumentSnapshot<Map<String, dynamic>>>> data = geoRef.within(
        center: current, radius: 5, field: 'position', strictMode: true);

    subs = data.listen(
      (queryLoc) {
        print('querylocation ${queryLoc})}');
        print('length:${queryLoc.length}');

        for (int i = 0; i < 5; i++) {
          bool a = queryLoc.elementAt(i).data()!["driverDetails"] != null;
          if (a) {
            Map t1 = queryLoc.elementAt(i).data()!["driverDetails"];
            List temp_list = [t1['imageurl'], t1['username'], t1['rating']];
            l1.add(temp_list);
            print('elementAt:${t1}');
          }
        }
        print("l1 data:${l1}");

        print("length of the t1:${t1.length}");
        if (queryLoc.length > 0) {
          setState(() {
            driver_details = true;
          });
        }
        // subs.cancel();
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
      cab_details = true;
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
    });
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
      cab_details = true;
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
    });
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
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.879,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Container(
                    height: (MediaQuery.of(context).size.height * 0.80) * 2,
                    child: Column(
                      children: [
                        Visibility(
                          visible: usingmappin,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.80,
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
                            height: MediaQuery.of(context).size.height * 0.80,
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
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.3),
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
                                                                  listen: false)
                                                              .pickuplocation !=
                                                          null) {
                                                    print("CASE -1");
                                                    await case1();
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
                                                    print("CASE -2");
                                                    LatLng pickup = Provider.of<
                                                                PickupMarkers>(
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
                                                padding: const EdgeInsets.only(
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
                                                              child: Container(
                                                                height: 25,
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
                                                              Provider.of<UserData>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .pickuplocation ==
                                                                      null
                                                                  ? "Current Location"
                                                                  : Provider.of<
                                                                              UserData>(
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
                                      Material(
                                        color: Colors.white,
                                        child: InkWell(
                                          onTap: () {
                                            print('Add Home');
                                          },
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0, horizontal: 10),
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
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Add home'),
                                                    SizedBox(
                                                      height: 4.0,
                                                    ),
                                                    Text(
                                                      "Add your home location",
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
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
                                            print('add work');
                                          },
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0, horizontal: 10),
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
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Add Work location'),
                                                    SizedBox(
                                                      height: 4.0,
                                                    ),
                                                    Text(
                                                      "Your office location",
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0, horizontal: 10),
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
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Pin location'),
                                                    SizedBox(
                                                      height: 4.0,
                                                    ),
                                                    Text(
                                                      "Use location pin",
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
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
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 12),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.my_location,
                                                              color: Colors
                                                                  .blueGrey,
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
                                                            const EdgeInsets
                                                                    .only(
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
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 12),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .location_on_rounded,
                                                              color: Colors
                                                                  .red[900],
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
                                                  width: MediaQuery.of(context)
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
                                                                horizontal: 3,
                                                                vertical: 1),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        child: Text(
                                                          "${Provider.of<DirectionsProvider>(context, listen: false).time.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).time.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).time.toString().length)} Min",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 10),
                                                        child: Container(
                                                          width: 50,
                                                          height: 1,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 3,
                                                                vertical: 1),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Text(
                                                            "${Provider.of<DirectionsProvider>(context, listen: false).distance.toString().substring(0, Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length > 4 ? 4 : Provider.of<DirectionsProvider>(context, listen: false).distance.toString().length)} KM"),
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
                                            selectedTileColor: Colors.grey,
                                            leading: Image.asset(
                                              'asset/images/mini_hatchback.jpg',
                                              width: 70,
                                              height: 75,
                                            ),
                                            selected: selectedCar == "Cab-Mini"
                                                ? true
                                                : false,
                                            title: Text(
                                              'Cab-Mini',
                                              style: TextStyle(
                                                  color:
                                                      selectedCar == "Cab-Mini"
                                                          ? Colors.blueGrey[600]
                                                          : Colors.black),
                                            ),
                                            trailing: Container(
                                              child: Text(
                                                (Provider.of<DirectionsProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .distance! *
                                                                24 +
                                                            60)
                                                        .ceil()
                                                        .toString() +
                                                    " \u{20B9}",
                                                style: TextStyle(
                                                    color: selectedCar ==
                                                            "Cab-Mini"
                                                        ? Colors.blueGrey[600]
                                                        : Colors.black),
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            focusColor: Colors.red,
                                            selectedTileColor: Colors.grey,
                                            leading: Image.asset(
                                              'asset/images/cab_.png',
                                              width: 70,
                                              height: 75,
                                            ),
                                            title: Text(
                                              'Cab-UX',
                                              style: TextStyle(
                                                  color: selectedCar == "Cab-UX"
                                                      ? Colors.blueGrey[600]
                                                      : Colors.black),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                selectedCar = "Cab-UX";
                                                print("Selected cab is Cab-UX");
                                              });
                                            },
                                            selected: selectedCar == "Cab-UX"
                                                ? true
                                                : false,
                                            trailing: Container(
                                              child: Text(
                                                (Provider.of<DirectionsProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .distance! *
                                                                35 +
                                                            100)
                                                        .ceil()
                                                        .toString() +
                                                    " \u{20B9}",
                                                style: TextStyle(
                                                    color: selectedCar ==
                                                            "Cab-UX"
                                                        ? Colors.blueGrey[600]
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
                                            selected: selectedCar == "Cab-Delux"
                                                ? true
                                                : false,
                                            selectedTileColor: Colors.black,
                                            tileColor: Colors.white,
                                            leading: Image.asset(
                                              'asset/images/cab_delux_icon.png',
                                              width: 70,
                                              height: 75,
                                            ),
                                            title: Text(
                                              'Cab-Delux',
                                              style: TextStyle(
                                                  color:
                                                      selectedCar == "Cab-Delux"
                                                          ? Colors.blueGrey[600]
                                                          : Colors.black),
                                            ),
                                            trailing: Container(
                                              child: Text(
                                                (Provider.of<DirectionsProvider>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .distance! *
                                                                42 +
                                                            150)
                                                        .ceil()
                                                        .toString() +
                                                    " \u{20B9}",
                                                style: TextStyle(
                                                    color: selectedCar ==
                                                            "Cab-Delux"
                                                        ? Colors.blueGrey[600]
                                                        : Colors.black),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                                        color: Colors.black87),
                                                  ),
                                                  iconSize: 24,
                                                  elevation: 0,
                                                  menuMaxHeight: 120,
                                                  itemHeight: 48,
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                  dropdownColor:
                                                      Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                                                              String>>(
                                                      (String value) {
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
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          2),
                                                              child: Text(''),
                                                            ),
                                                            SizedBox(
                                                              width: 9,
                                                            ),
                                                            Image.asset(
                                                              "asset/images/$value.png",
                                                              fit: BoxFit.cover,
                                                            ),
                                                            value == "Cash"
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
                                                  onPressed: getDriverDeatials,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      24,
                                                                  vertical: 8),
                                                          primary:
                                                              Colors.black),
                                                  icon: Icon(LineIcons.car),
                                                  label: Text("Search Cab"),
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
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            height: 280,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            alignment: Alignment.center,
                                            child: ListView.builder(
                                              itemCount: l1.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                if (l1.length == 0) {
                                                  return Center(
                                                    child: Text(
                                                        "No Drivers found near by",
                                                        style:
                                                            GoogleFonts.ubuntu(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                  );
                                                } else {
                                                  return Material(
                                                    color: Colors.white,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      splashColor:
                                                          Colors.blueGrey[100],
                                                      onTap: () {
                                                        print(
                                                            '${l1[index][1]} is selected as driver');
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 3),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25),
                                                                  child: Image
                                                                      .network(
                                                                    l1[index]
                                                                        [0],
                                                                    width: 50,
                                                                    height: 50,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  l1[index][1],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style: GoogleFonts
                                                                      .dmSans(
                                                                          fontSize:
                                                                              17),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              width: 50,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Icon(
                                                                    LineIcons
                                                                        .starAlt,
                                                                    color: Colors
                                                                        .amber,
                                                                  ),
                                                                  Text(
                                                                    "${l1[index][2]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: GoogleFonts
                                                                        .dmSans(
                                                                      fontSize:
                                                                          15,
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
                                                }
                                              },
                                            ),
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
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
