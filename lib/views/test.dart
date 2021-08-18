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
        body: Stack(
          children: [
            Positioned.fill(
              top: 0,
              left: 0,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [],
                ),
              ),
            ),
            Positioned(
              //!Blue
              top: 0,
              left: 0,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .50,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(30, 30, 30, 1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black)],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.keyboard_backspace,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 70,
                      left: 134,
                      child: Text(
                        'Sign in',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                        // style: GoogleFonts.aBeeZee(
                        //     color: Colors.white, fontSize: 30),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: 0,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .50,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.4),
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome",
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        cursorWidth: 1,
                        decoration: InputDecoration(
                          hintText: "Username",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        cursorWidth: 1,
                        decoration: InputDecoration(
                          hintText: "Password",
                          border: UnderlineInputBorder(),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                        primary: Colors.black87,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
