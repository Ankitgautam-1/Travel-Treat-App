import 'package:app/Data/accountProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MyTrips extends StatefulWidget {
  const MyTrips({Key? key}) : super(key: key);

  @override
  State<MyTrips> createState() => _MyTripsState();
}

class _MyTripsState extends State<MyTrips> {
  Future<QuerySnapshot<Map<String, dynamic>>> getTrips() async {
    final _firestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> _user = await _firestore
        .collection('Trip_collection')
        .where("userDetails.user_uid",
            isEqualTo: Provider.of<AccountProvider>(context, listen: false)
                .userAccount
                .Uid)
        .get();
    _user.docs.forEach((element) {
      var drivers_name = element.data()["driverDetails"]["driver_name"];
      print("Driver Name : $drivers_name");
    });
    return _user;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: getTrips(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                List open = List.filled(snapshot.data!.docs.length, false);

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemCount: snapshot.data!.docs.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    DateTime startTrip = DateTime.parse(
                        snapshot.data!.docs[index].data()["startTrip"]);
                    DateTime endTrip = DateTime.parse(
                        snapshot.data!.docs[index].data()["trip_end_time"]);

                    String tripDate = startTrip.day.toString() +
                        "/" +
                        startTrip.month.toString() +
                        "/" +
                        startTrip.year.toString();

                    var min =
                        endTrip.difference(startTrip).inMinutes.toString();
                    var hour = endTrip.difference(startTrip).inHours.toString();
                    return _buildPlayerModelList(snapshot.data!.docs[index],
                        tripDate, hour, min, startTrip, endTrip);
                  },
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  Widget _buildPlayerModelList(items, tripDate, hour, min, startTrip, endTrip) {
    return Card(
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        title: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.my_location_rounded),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    items
                        .data()["userDetails"]["user_pickup_address"]
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_rounded),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    items
                        .data()["userDetails"]["user_destination_address"]
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tripDate +
                      "," +
                      endTrip.hour.toString() +
                      ":" +
                      endTrip.minute.toString(),
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                    " \u{20B9}" +
                        items
                            .data()["paymentDetails"]["payment_amount"]
                            .toString(),
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
        children: <Widget>[
          ListTile(
            hoverColor: Colors.white30,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Drivers Details",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          foregroundImage: NetworkImage(
                              items.data()["driverDetails"]["driver_profile"]),
                          backgroundColor: Colors.blueGrey.shade300,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_box_sharp),
                                SizedBox(width: 10),
                                Text(
                                  items
                                      .data()["driverDetails"]["driver_name"]
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.phone_android_rounded),
                                SizedBox(width: 10),
                                Text(
                                  items
                                      .data()["driverDetails"]["driver_phone"]
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.car_repair),
                                SizedBox(width: 10),
                                Text(
                                  items
                                      .data()["cabDetails"]["cab_number"]
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.star),
                                SizedBox(width: 10),
                                Text(
                                  items
                                      .data()["driverDetails"]["driver_rating"]
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            )
                          ],
                        )
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
  }
}
