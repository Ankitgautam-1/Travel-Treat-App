import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:app/screen/Homepage.dart';
import 'package:app/screen/Welcome.dart';
import 'package:app/screen/Dashboard.dart';
import 'package:app/screen/number_verify.dart';
import 'package:app/screen/otp.dart';
import 'package:app/screen/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

var email;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Ubuntu',
      ),
      home: SafeArea(
        child:
            // Otpverify(verificationId: '123456', num: '12334') //!Change here
            MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkemail();
  }

  void checkemail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('email') != null) {
      email = prefs.getString('email')!;
    } else {
      email = "";
    }

    setState(() {
      email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 5500,
      splash: 'asset/Animation/cab-animation.gif',
      backgroundColor: Colors.white,
      nextScreen: email == "" ? Welcome() : Dashboard(),
      splashIconSize: 350,
    );
  }
}
