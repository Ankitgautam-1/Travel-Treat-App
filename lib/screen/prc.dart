// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class Prc extends StatefulWidget {
//   @override
//   _PrcState createState() => _PrcState();
// }

// class _PrcState extends State<Prc> {
//   FirebaseAuth auth = FirebaseAuth.instance;
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           toolbarHeight: 40,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(
//               Icons.arrow_back,
//               color: Colors.black,
//               size: 25,
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             //mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: 35,
//               ),
//               Text(
//                 'OTP Verification',
//                 style: TextStyle(
//                   fontSize: 35,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 'Please don\'t share your OTP ',
//                 style: TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//               Image.asset(
//                 'asset/images/email_verification_bg.png',
//                 height: 300,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     height: 85,
//                     width: 50,
//                     child: TextFormField(
//                       autofocus: true,
//                       onChanged: (value) {
//                         if (value.length == 1) {
//                           FocusScope.of(context).nextFocus();
//                         }
//                       },
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       maxLength: 1,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 24,
//                       ),
//                       decoration: InputDecoration(
//                         counterText: "",
//                         focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(width: 2.0, color: Colors.black),
//                         ),
//                         border: OutlineInputBorder(),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(width: 1.4),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: 85,
//                     width: 50,
//                     child: TextFormField(
//                       autofocus: true,
//                       onChanged: (value) {
//                         if (value.length == 1) {
//                           FocusScope.of(context).nextFocus();
//                         }
//                         if (value.length != 1) {
//                           FocusScope.of(context).previousFocus();
//                         }
//                       },
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       maxLength: 1,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 24,
//                       ),
//                       decoration: InputDecoration(
//                         counterText: "",
//                         border: OutlineInputBorder(),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(width: 2.0, color: Colors.black),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(width: 2),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: 85,
//                     width: 50,
//                     child: TextFormField(
//                       autofocus: true,
//                       onChanged: (value) {
//                         if (value.length == 1) {
//                           FocusScope.of(context).nextFocus();
//                         }
//                         if (value.length != 1) {
//                           FocusScope.of(context).previousFocus();
//                         }
//                       },
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       maxLength: 1,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 24,
//                       ),
//                       decoration: InputDecoration(
//                         counterText: "",
//                         border: OutlineInputBorder(),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(width: 2.0, color: Colors.black),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(width: 2),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: 85,
//                     width: 50,
//                     child: TextFormField(
//                       autofocus: true,
//                       onChanged: (value) {
//                         if (value.length == 1) {
//                           FocusScope.of(context).nextFocus();
//                         }
//                         if (value.length != 1) {
//                           FocusScope.of(context).previousFocus();
//                         }
//                       },
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       maxLength: 1,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 24,
//                       ),
//                       decoration: InputDecoration(
//                         counterText: "",
//                         border: OutlineInputBorder(),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(width: 2.0, color: Colors.black),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(width: 2),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: 85,
//                     width: 50,
//                     child: TextFormField(
//                       autofocus: true,
//                       onChanged: (value) {
//                         if (value.length == 1) {
//                           FocusScope.of(context).nextFocus();
//                         }
//                         if (value.length != 1) {
//                           FocusScope.of(context).previousFocus();
//                         }
//                       },
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       maxLength: 1,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 24,
//                       ),
//                       decoration: InputDecoration(
//                         counterText: "",
//                         border: OutlineInputBorder(),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(width: 2.0, color: Colors.black),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(width: 2),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: 85,
//                     width: 50,
//                     child: TextFormField(
//                       autofocus: true,
//                       onChanged: (value) {
//                         if (value.length == 1) {
//                           FocusScope.of(context).nextFocus();
//                         }
//                         if (value.length != 1) {
//                           FocusScope.of(context).previousFocus();
//                         }
//                       },
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       maxLength: 1,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 24,
//                       ),
//                       decoration: InputDecoration(
//                         counterText: "",
//                         border: OutlineInputBorder(),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               BorderSide(width: 2.0, color: Colors.black),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(width: 2),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     primary: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     )),
//                 onPressed: () async {},
//                 child: Text('Verify OTP'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future verify() async {}
// }
