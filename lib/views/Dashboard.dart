// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:prc/views/Welcome.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Dashboard extends StatefulWidget {
//   const Dashboard({Key? key}) : super(key: key);

//   @override
//   _DashboardState createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   void logoutgoogleuser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('uid');
//     try {
//       await GoogleSignIn().signOut();
//     } catch (e) {}
//     await FirebaseAuth.instance.signOut();

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Welcome(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: SingleChildScrollView(
//           child: Container(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset('asset/images/Welcome.jpg'),
//                 ElevatedButton(
//                   onPressed: logoutgoogleuser,
//                   child: Text('Log Out'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           backgroundColor: Colors.black,
//           type: BottomNavigationBarType.fixed,
//           unselectedItemColor: Colors.white70,
//           selectedItemColor: Colors.white,
//           selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
//           items: [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_filled),
//               label: "Home",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.search),
//               label: "Discover",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.chat_bubble_outline_outlined),
//               label: "Inbox",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline_outlined),
//               label: "Me",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
