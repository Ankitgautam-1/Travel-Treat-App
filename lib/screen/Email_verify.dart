import 'dart:async';

import 'package:app/main.dart';
import 'package:app/screen/Dashboard.dart';
import 'package:app/screen/Phone_verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EmailVerify extends StatefulWidget {
  List<String> data;
  EmailVerify({required this.data});

  @override
  _EmailVerifyState createState() => _EmailVerifyState(data: data);
}

class _EmailVerifyState extends State<EmailVerify> {
  List<String> data;
  _EmailVerifyState({required this.data});

  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  bool isdisable = false;
  @override
  void initState() {
    print(data);
    print('Checking for verification');
    timer = Timer.periodic(Duration(seconds: 4), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () {
              Navigator.pop(context);
              timer!.cancel();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 30,
              ),
              Center(
                child: Image.asset(
                  'asset/images/email_verification_bg.png',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Email Verification',
                style: TextStyle(
                  fontSize: 35,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Please check your Email & Verify',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkEmailVerified() async {
    print('inside checkEmailverified');
    user = auth.currentUser;
    print("Checking for user $user");
    await user!.reload();
    if (user!.emailVerified) {
      timer!.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }
}
