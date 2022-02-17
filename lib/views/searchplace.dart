import 'package:app/Data/pickuploc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app/Data/destinationmarkers.dart';
import 'package:app/Data/userData.dart';
import 'package:app/services/httpreq.dart';
import 'package:provider/provider.dart';

class SearchPlace extends StatefulWidget {
  final FirebaseApp app;
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
  bool hasData = false;
  List placesList = [];
  bool loading = false;
  bool loadingforpickup = false;
  bool destination = false;
  bool loadingfordestination = false;
  bool pickup = false;
  void pickupsearch(String placeString) async {
    FocusScope.of(context)
        .unfocus(); //to hide the keyboard by unfocusing on textformfield
    setState(() {
      loadingforpickup = true;
      pickup = false;
      destination = false;
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
    FocusScope.of(context)
        .unfocus(); //to hide the keyboard by unfocusing on textformfield
    setState(() {
      pickup = false;
      destination = false;
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
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Search Location",
            style: GoogleFonts.openSans(color: Colors.white, fontSize: 18),
          ),
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.95,
            padding: EdgeInsets.only(top: 35),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.my_location,
                      size: 24,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: TextFormField(
                        cursorColor: Colors.black,
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
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Pick Up?",
                          hintStyle: GoogleFonts.openSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black54),
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
                      Icons.location_on,
                      size: 24,
                      color: Colors.redAccent[700],
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: TextFormField(
                        onFieldSubmitted: (val) => destinationsearch(val),
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        keyboardType: TextInputType.streetAddress,
                        initialValue: Provider.of<DestinationMarkers>(context)
                                    .places !=
                                null
                            ? Provider.of<DestinationMarkers>(context).address
                            : "",
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: "Where to?",
                          hintStyle: GoogleFonts.openSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54),
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
                  height: 36,
                ),
                pickup
                    ? SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          height: 300,
                          child: ListView.builder(
                              itemCount: placesList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Provider.of<UserData>(context,
                                            listen: false)
                                        .updatepickuplocation(null);
                                    print(
                                      'lat ->${placesList[index]["location"]["lat"]} lng ->${placesList[index]["location"]["lng"]}',
                                    );
                                    LatLng place = LatLng(
                                        placesList[index]["location"]["lat"],
                                        placesList[index]["location"]["lng"]);
                                    String address =
                                        placesList[index]["address"];
                                    Provider.of<PickupMarkers>(context,
                                            listen: false)
                                        .updatePickupMarkers(place, address);
                                    print("place info:->$place");
                                    Get.back();
                                    onPlaceSelect();
                                  },
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.share_location_outlined,
                                      color: Colors.blueGrey.shade800,
                                      size: 30,
                                    ),
                                    title: Text(
                                      '${placesList[index]["address"]}',
                                      style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      )
                    : destination
                        ? Container()
                        : loadingforpickup
                            ? CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              )
                            : Container(),
                destination
                    ? SingleChildScrollView(
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            height: 300,
                            child: ListView.builder(
                              itemCount: placesList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    print(
                                      'lat in destination ->${placesList[index]["location"]["lat"]} lng ->${placesList[index]["location"]["lng"]}',
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
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.share_location_outlined,
                                      color: Colors.blueGrey.shade800,
                                    ),
                                    title: Text(
                                      '${placesList[index]["address"]}',
                                      style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : pickup
                        ? Container()
                        : loadingfordestination
                            ? CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 3,
                              )
                            : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
