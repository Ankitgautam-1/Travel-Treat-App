// import 'package:flutter/material.dart';
// import 'package:timer_count_down/timer_controller.dart';
// import 'package:timer_count_down/timer_count_down.dart';

// class Count extends StatefulWidget {
//   const Count({Key? key}) : super(key: key);

//   @override
//   _CountState createState() => _CountState();
// }

// class _CountState extends State<Count> {
//   CountdownController _controller = CountdownController(autoStart: true);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: <Widget>[
//                     // Start
//                     ElevatedButton(
//                       child: Text('Start'),
//                       onPressed: () {
//                         _controller.start();
//                       },
//                     ),
//                     // Pause
//                     ElevatedButton(
//                       child: Text('Pause'),
//                       onPressed: () {
//                         _controller.pause();
//                       },
//                     ),
//                     // Resume
//                     ElevatedButton(
//                       child: Text('Resume'),
//                       onPressed: () {
//                         _controller.resume();
//                       },
//                     ),
//                     // Stop
//                     ElevatedButton(
//                       child: Text('Restart'),
//                       onPressed: () {
//                         _controller.restart();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               Countdown(
//                 controller: _controller,
//                 seconds: 30,
//                 build: (_, double time) => Text(
//                   time.toInt().toString(),
//                   style: TextStyle(
//                     fontSize: 100,
//                   ),
//                 ),
//                 interval: Duration(seconds: 1),
//                 onFinished: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Timer is done!'),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class OTPPage extends StatefulWidget {
//   const OTPPage({Key? key}) : super(key: key);

//   @override
//   _OTPPageState createState() => _OTPPageState();
// }

// class _OTPPageState extends State<OTPPage> {
//   TextEditingController _1st = TextEditingController();
//   TextEditingController _2nd = TextEditingController();
//   TextEditingController _3rd = TextEditingController();
//   TextEditingController _4th = TextEditingController();
//   TextEditingController _5th = TextEditingController();
//   TextEditingController _6th = TextEditingController();
//   String _otp = "";
//   Future verify(String otp) async {
//     print('submit');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SingleChildScrollView(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 IconButton(
//                   onPressed: () {},
//                   icon: Icon(
//                     Icons.arrow_back,
//                     color: Colors.black,
//                   ),
//                 ),
//                 Center(
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 20),
//                         child: Image.asset(
//                           'asset/images/Mobile_verify.jpg',
//                           width: 280,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       Text(
//                         'OTP Verification',
//                         style: TextStyle(
//                           fontSize: 28,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
//                   child: Text(
//                     'We will send you an One Time Password on this mobile number',
//                     textAlign: TextAlign.left,
//                     style: GoogleFonts.ubuntu(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.03,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 58,
//                       width: 45,
//                       child: TextFormField(
//                         cursorColor: Colors.black,
//                         controller: _1st,
//                         autofocus: true,
//                         onChanged: (value) {
//                           if (value.length == 1) {
//                             FocusScope.of(context).nextFocus();
//                           }
//                         },
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                         ),
//                         decoration: InputDecoration(
//                           counterText: "",
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 BorderSide(width: 2.0, color: Colors.black),
//                           ),
//                           border: OutlineInputBorder(),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(width: 1.4),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 58,
//                       width: 45,
//                       child: TextFormField(
//                         cursorColor: Colors.black,
//                         controller: _2nd,
//                         autofocus: true,
//                         onChanged: (value) {
//                           if (value.length == 1) {
//                             FocusScope.of(context).nextFocus();
//                           }
//                           if (value.length != 1) {
//                             FocusScope.of(context).previousFocus();
//                           }
//                         },
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                         ),
//                         decoration: InputDecoration(
//                           counterText: "",
//                           border: OutlineInputBorder(),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 BorderSide(width: 2.0, color: Colors.black),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(width: 1.4),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 58,
//                       width: 45,
//                       child: TextFormField(
//                         cursorColor: Colors.black,
//                         controller: _3rd,
//                         autofocus: true,
//                         onChanged: (value) {
//                           if (value.length == 1) {
//                             FocusScope.of(context).nextFocus();
//                           }
//                           if (value.length != 1) {
//                             FocusScope.of(context).previousFocus();
//                           }
//                         },
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                         ),
//                         decoration: InputDecoration(
//                           counterText: "",
//                           border: OutlineInputBorder(),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 BorderSide(width: 2.0, color: Colors.black),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(width: 1.4),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 58,
//                       width: 45,
//                       child: TextFormField(
//                         cursorColor: Colors.black,
//                         controller: _4th,
//                         autofocus: true,
//                         onChanged: (value) {
//                           if (value.length == 1) {
//                             FocusScope.of(context).nextFocus();
//                           }
//                           if (value.length != 1) {
//                             FocusScope.of(context).previousFocus();
//                           }
//                         },
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                         ),
//                         decoration: InputDecoration(
//                           counterText: "",
//                           border: OutlineInputBorder(),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 BorderSide(width: 2.0, color: Colors.black),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(width: 1.4),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 58,
//                       width: 45,
//                       child: TextFormField(
//                         cursorColor: Colors.black,
//                         controller: _5th,
//                         autofocus: true,
//                         onChanged: (value) {
//                           if (value.length == 1) {
//                             FocusScope.of(context).nextFocus();
//                           }
//                           if (value.length != 1) {
//                             FocusScope.of(context).previousFocus();
//                           }
//                         },
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                         ),
//                         decoration: InputDecoration(
//                           counterText: "",
//                           border: OutlineInputBorder(),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 BorderSide(width: 2.0, color: Colors.black),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(width: 1.4),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       height: 58,
//                       width: 45,
//                       child: TextFormField(
//                         cursorColor: Colors.black,
//                         controller: _6th,
//                         autofocus: true,
//                         onChanged: (value) {
//                           if (value.length == 1) {
//                             FocusScope.of(context).nextFocus();
//                           }
//                           if (value.length != 1) {
//                             FocusScope.of(context).previousFocus();
//                           }
//                         },
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 24,
//                         ),
//                         decoration: InputDecoration(
//                           counterText: "",
//                           border: OutlineInputBorder(),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 BorderSide(width: 2.0, color: Colors.black),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(width: 1.4),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.03,
//                 ),
//                 Center(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 90, vertical: 12),
//                       primary: Color.fromRGBO(0, 0, 0, 1),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(13.0),
//                       ),
//                     ),
//                     onPressed: () async {
//                       FocusScope.of(context)
//                           .unfocus(); //to hide the keyboard by unfocusing on textformfield
//                       _otp = _1st.text +
//                           _2nd.text +
//                           _3rd.text +
//                           _4th.text +
//                           _5th.text +
//                           _6th.text;
//                       print("Your otp is  $_otp");
//                       await verify(_otp);
//                     },
//                     child: Text(
//                       'Verify OTP',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
