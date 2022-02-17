import 'package:app/views/Signin.dart';
import 'package:app/views/Signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Test extends StatefulWidget {
  final FirebaseApp app;
  Test({required this.app});
  @override
  _TestState createState() => _TestState(app: app);
}

class _TestState extends State<Test> {
  FirebaseApp app;
  _TestState({required this.app});
  @override
  Widget build(BuildContext context) {
    bool isloading = false;
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  height: 220,
                  child: Column(
                    children: [
                      SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 150),
                        child: Text(
                          'Welcome to',
                          style: TextStyle(
                            fontSize: 32,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 150),
                        child: Text(
                          'Travel Treat',
                          style: TextStyle(
                            fontSize: 32,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Image.asset(
                        'asset/images/cab.jpg',
                        width: 360,
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 80),
                          primary: Colors.black87,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                        ),
                        onPressed: () {
                          Get.to(SignIn(app: app));
                        },
                        child: Text(
                          ' Sign In ',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      isloading
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                height: 20,
                                width: 20,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 20,
                            ),
                      Center(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black,
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 13, vertical: 6),
                          ),
                          label: Text(
                            'Sign In with Google',
                            style:
                                TextStyle(fontFamily: 'Ubuntu', fontSize: 17),
                          ),
                          icon: Image.asset(
                            'asset/images/google_logo.png',
                            width: 35,
                          ),
                          onPressed: () async {},
                        ),
                      ),
                      SizedBox(
                        height: 10,
                        child: TextButton(
                          onPressed: () {
                            Get.to(SignIn(app: app));
                          },
                          child: Text("Login"),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an Account ?',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(SignUp(app: app));
                            },
                            child: Text(
                              ' Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
