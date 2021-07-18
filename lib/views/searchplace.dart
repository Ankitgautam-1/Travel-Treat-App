import 'package:app/Data/pickuploc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app/Data/destinationmarkers.dart';
import 'package:app/Data/userData.dart';
import 'package:app/models/userAddress.dart';
import 'package:app/services/httpreq.dart';
import 'package:app/views/Maps.dart';
import 'package:provider/provider.dart';

class SearchPlace extends StatefulWidget {
  FirebaseApp app;
  final VoidCallback onPlaceSelect;
  SearchPlace({required this.app, required this.onPlaceSelect});

  @override
  _SearchPlaceState createState() =>
      _SearchPlaceState(app: app, onPlaceSelect: onPlaceSelect);
}

class _SearchPlaceState extends State<SearchPlace> {
  FirebaseApp app;
  final VoidCallback onPlaceSelect;
  _SearchPlaceState({required this.app, required this.onPlaceSelect});
  final CameraPosition _initpostion = CameraPosition(
    target: LatLng(19.217107, 73.08338),
    zoom: 17.1414,
  );
  bool hasData = false;
  TextEditingController _searchloc = TextEditingController();
  TextEditingController _pickuploc = TextEditingController();
  List placesList = [];
  bool loading = false;
  bool loadingforpickup = false;
  bool destination = false;
  bool loadingfordestination = false;
  bool pickup = false;
  void pickupsearch(String placeString) async {
    setState(() {
      loadingforpickup = true;
    });
    if (placeString.length != 0) {
      var places = Httpreq(
          place: placeString, endpoint: "FindPlaceByText", query: "text");
      var res = await places.getPlace();
      if (res != "Failed") {
        placesList = res['results'];
        print("List Of Places:>$placesList");
        if (placesList.length > 0) {
          setState(() {
            pickup = true;
            loadingforpickup = false;
          });
        }
      }
      print(res);
    }
  }

  void destinationsearch(String placeString) async {
    setState(() {
      loadingfordestination = true;
    });
    if (placeString.length != 0) {
      var places = Httpreq(
          place: placeString, endpoint: "FindPlaceByText", query: "text");
      var res = await places.getPlace();
      if (res != "Failed") {
        placesList = res['results'];
        print("List Of Places:>$placesList");
        if (placesList.length > 0) {
          setState(() {
            destination = true;
            loadingfordestination = false;
          });
        }
      }
      print(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.95,
            child: Column(
              children: [
                SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.my_location_rounded,
                      size: 24,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: TextFormField(
                        initialValue: Provider.of<UserData>(context,
                                        listen: false)
                                    .pickuplocation !=
                                null
                            ? Provider.of<UserData>(context)
                                .pickuplocation!
                                .placeAddres
                            : Provider.of<PickupMarkers>(context, listen: false)
                                        .places !=
                                    null
                                ? Provider.of<PickupMarkers>(context,
                                        listen: false)
                                    .address
                                : "",
                        keyboardType: TextInputType.streetAddress,
                        onFieldSubmitted: (val) => pickupsearch(val),
                        decoration: InputDecoration(
                          hintText: "Pick Up?",
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 24,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: TextFormField(
                        onFieldSubmitted: (val) => destinationsearch(val),
                        keyboardType: TextInputType.streetAddress,
                        initialValue: Provider.of<DestinationMarkers>(context)
                                    .places !=
                                null
                            ? Provider.of<DestinationMarkers>(context).address
                            : "",
                        decoration: InputDecoration(
                          hintText: "Where to?",
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 28,
                ),
                pickup
                    ? SingleChildScrollView(
                        child: Container(
                          height: 300,
                          child: ListView.builder(
                              itemCount: placesList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: GestureDetector(
                                      onTap: () {
                                        Provider.of<UserData>(context,
                                                listen: false)
                                            .updatepickuplocation(null);
                                        print(
                                          'lat ->${placesList[index]["location"]["lat"]} lng ->${placesList[index]["location"]["lng"]}',
                                        );
                                        LatLng place = LatLng(
                                            placesList[index]["location"]
                                                ["lat"],
                                            placesList[index]["location"]
                                                ["lng"]);
                                        String address =
                                            placesList[index]["address"];
                                        Provider.of<PickupMarkers>(context,
                                                listen: false)
                                            .updatePickupMarkers(
                                                place, address);
                                        print("place info:->$place");
                                        Get.back();
                                        onPlaceSelect();
                                      },
                                      child: Icon(Icons.location_on_rounded)),
                                  title:
                                      Text('${placesList[index]["address"]}'),
                                );
                              }),
                        ),
                      )
                    : destination
                        ? Container()
                        : loadingforpickup
                            ? CircularProgressIndicator()
                            : Container(
                                child: Text('No Places to be found'),
                              ),
                destination
                    ? SingleChildScrollView(
                        child: Container(
                          height: 300,
                          child: ListView.builder(
                            itemCount: placesList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: GestureDetector(
                                    onTap: () {
                                      print(
                                        'lat ->${placesList[index]["location"]["lat"]} lng ->${placesList[index]["location"]["lng"]}',
                                      );
                                      LatLng place = LatLng(
                                          placesList[index]["location"]["lat"],
                                          placesList[index]["location"]["lng"]);

                                      String address =
                                          placesList[index]["address"];
                                      Provider.of<DestinationMarkers>(context,
                                              listen: false)
                                          .updateDestinationMarkers(
                                              place, address);
                                      print("place info:->$place");
                                      Get.back();
                                      onPlaceSelect();
                                    },
                                    child: Icon(Icons.location_on_rounded)),
                                title: Text('${placesList[index]["address"]}'),
                              );
                            },
                          ),
                        ),
                      )
                    : loadingfordestination
                        ? CircularProgressIndicator()
                        : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
