// import 'dart:io';

// import 'package:app/Data/accountProvider.dart';
// import 'package:app/Data/destinationmarkers.dart';
// import 'package:app/Data/image.dart';
// import 'package:app/Data/pickuploc.dart';
// import 'package:app/Data/userData.dart';
// import 'package:app/models/pushnotification.dart';
// import 'package:app/models/userAccount.dart';
// import 'package:app/views/Maps.dart';
// import 'package:app/views/Signin.dart';
// import 'package:app/views/Signup.dart';
// import 'package:app/views/Welcome.dart';
// import 'package:app/views/accounts.dart';
// import 'package:app/views/plan.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Dashboard extends StatefulWidget {
//   final FirebaseApp app;
//   Dashboard({required this.app});
//   @override
//   _DashboardState createState() => _DashboardState(app: app);
// }

// class _DashboardState extends State<Dashboard> {
//   final FirebaseApp app;
//   _DashboardState({required this.app});
//   int selectedindex = 0;
//   PageController _pagecontroller = PageController();
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

//   void _onpagechanged(int index) {
//     setState(() {
//       selectedindex = index;
//     });
//   }

//   @override
//   void initState() {
//     print("in init");
//     super.initState();
//     getnotification();
//     setupnotification();
//   }

//   void getnotification() async {
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails("chnanelId", "channellname",
//             channelDescription:
//                 "The Travel Treat app requires notification service to assure user and alert on required time.",
//             importance: Importance.high,
//             priority: Priority.high);
//   }

//   Future<void> setupnotification() async {
//     print("in");
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       print("getting data ");
//       print(message.notification);
//       print(message.data);
//       AndroidNotificationDetails androidPlatformChannelSpecifics =
//           AndroidNotificationDetails("chnanelId", "channellname",
//               channelDescription:
//                   "The Travel Treat app requires notification service to assure user and alert on required time.",
//               importance: Importance.high,
//               priority: Priority.high);
//       NotificationDetails platformChannelSpecifics =
//           NotificationDetails(android: androidPlatformChannelSpecifics);
//       await FlutterLocalNotificationsPlugin()
//           .show(12345, "message.notification!.title",
//               "message.notification!.body", platformChannelSpecifics,
//               payload: 'sending from user')
//           .then((value) => print(" print done"))
//           .onError((error, stackTrace) => print("got error"));
//     });
//   }

//   void _onnavigationmenu(int selectedindex) {
//     _pagecontroller.jumpToPage(selectedindex);
//   }

//   void logoutgoogleuser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('Username');
//     await prefs.remove('Email');
//     await prefs.remove('Ph');
//     await prefs.remove('Uid');
//     await prefs.remove('Image');
//     await prefs.remove('emph');

//     try {
//       await GoogleSignIn().signOut();
//     } catch (e) {}
//     await FirebaseAuth.instance.signOut();
//     if (Provider.of<ImageData>(context, listen: false).image != null) {
//       Provider.of<ImageData>(context, listen: false).updateimage(null);
//     }
//     UserAccount userAccount = UserAccount(
//         Email: "", Image: "", Ph: "", Uid: "", Username: "", emph: "");
//     Provider.of<AccountProvider>(context, listen: false)
//         .updateuseraccount(userAccount);
//     Provider.of<UserData>(context, listen: false).updatepickuplocation(null);
//     Provider.of<PickupMarkers>(context, listen: false)
//         .updatePickupMarkers(null, null);
//     Provider.of<DestinationMarkers>(context, listen: false)
//         .updateDestinationMarkers(null, null);

//     Get.off(
//       Welcome(app: app),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("Dashboard");
//     setupnotification();
//     return SafeArea(
//         child: Scaffold(
//       key: _scaffoldKey,
//       body: PageView(
//         controller: _pagecontroller,
//         children: [
//           Stack(
//             children: [
//               Maps(app: app),
//               Padding(
//                 padding: const EdgeInsets.only(top: 15, left: 20),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Color.fromRGBO(255, 255, 255, .7),
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     tooltip: "Menu",
//                     onPressed: () {
//                       _scaffoldKey.currentState!.openDrawer();
//                     },
//                     icon: Icon(Icons.menu),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Plans(),
//           Accounts(),
//         ],
//         onPageChanged: _onpagechanged,
//         physics: NeverScrollableScrollPhysics(),
//       ),
//       drawer: Drawer(
//         elevation: 1,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               profile(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         elevation: 0.2,
//         iconSize: 18,
//         backgroundColor: Color.fromRGBO(30, 30, 30, 1),
//         currentIndex: selectedindex,
//         type: BottomNavigationBarType.fixed,
//         selectedFontSize: 12,
//         items: [
//           BottomNavigationBarItem(
//               tooltip: 'Booking',
//               icon: Icon(CupertinoIcons.location_solid,
//                   color: selectedindex == 0 ? Colors.blue : Colors.white60),
//               title: Text('Maps',
//                   style: TextStyle(
//                       fontSize: 12,
//                       color:
//                           selectedindex == 0 ? Colors.blue : Colors.white60))),
//           BottomNavigationBarItem(
//             tooltip: 'Create a plan',
//             icon: Icon(
//                 selectedindex == 1
//                     ? CupertinoIcons.news_solid
//                     : CupertinoIcons.news,
//                 color: selectedindex == 1 ? Colors.blue : Colors.white60),
//             title: Text(
//               'Plan',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: selectedindex == 1 ? Colors.blue : Colors.white60,
//               ),
//             ),
//           ),
//           BottomNavigationBarItem(
//               tooltip: 'User account',
//               icon: Container(
//                 padding: EdgeInsets.only(top: 6),
//                 child: CircleAvatar(
//                   radius: 15,
//                   backgroundImage: FileImage(File(
//                       Provider.of<AccountProvider>(context, listen: false)
//                           .userAccount
//                           .Image!)),
//                 ),
//               ),
//               title: Text('',
//                   style: TextStyle(
//                       fontSize: 12,
//                       color:
//                           selectedindex == 2 ? Colors.blue : Colors.white60)))
//         ],
//         onTap: _onnavigationmenu,
//       ),
//     ));
//   }

//   Widget profile() {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.96,
//       color: Colors.white,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Container(
//             color: Color.fromRGBO(30, 30, 30, 1),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Center(
//                   child: Provider.of<ImageData>(context, listen: false).image ==
//                           null
//                       ? CircleAvatar(
//                           backgroundColor: Colors.black26,
//                           radius: 55,
//                           backgroundImage: FileImage(File(
//                               Provider.of<AccountProvider>(context,
//                                       listen: false)
//                                   .userAccount
//                                   .Image!)),
//                         )
//                       : CircleAvatar(
//                           backgroundColor: Colors.black26,
//                           radius: 55,
//                           backgroundImage: FileImage(
//                               Provider.of<ImageData>(context, listen: false)
//                                   .image!),
//                         ),
//                 ),
//                 SizedBox(
//                   height: 35,
//                 ),
//                 Text(
//                   Provider.of<AccountProvider>(context, listen: false)
//                       .userAccount
//                       .Username,
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.white),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Text(
//                   Provider.of<AccountProvider>(context, listen: false)
//                       .userAccount
//                       .Email,
//                   style: TextStyle(fontSize: 13, color: Colors.white),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: Icon(
//               Icons.logout_sharp,
//             ),
//             title: Text('Log Out'),
//             selected: false,
//             onTap: () {
//               logoutgoogleuser();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
