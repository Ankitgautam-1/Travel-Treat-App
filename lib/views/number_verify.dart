import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app/views/Phone_verify.dart';

var ph;

class Numverify extends StatefulWidget {
  final User user;
  final FirebaseApp app;
  Numverify({required this.user, required this.app});
  @override
  _NumverifyState createState() => _NumverifyState(user: user, app: app);
}

class _NumverifyState extends State<Numverify> {
  FirebaseApp app;
  List<dynamic> data = [];
  User user;
  _NumverifyState({required this.user, required this.app});
  bool isloading = false;
  final GlobalKey<ScaffoldState> _scaffodkey = GlobalKey();
  final _formkey = GlobalKey<FormState>();
  final TextEditingController phcontroller = TextEditingController();
  void phoneverify() async {
    setState(() {
      isloading = true;
    });
    if (_formkey.currentState!.validate()) {
      print(" data :");
      print(user);
      print(phcontroller.text);
      print(user.displayName);
      print(user.email);
      data = [
        user.displayName!,
        user.email!,
        phcontroller.text,
        user.photoURL!,
      ];
      try {
        _formkey.currentState!.save();
        print(phcontroller.text);
        Get.off(
          Prc(data: data, isgoogle: true, app: app),
        );
      } catch (e) {
        Get.snackbar("Phone verification", "Error Occure $e");
        setState(
          () {
            isloading = false;
          },
        );
      }
    } else {
      print("Errorrrrrrrrrrrrrrrrr");
      setState(() {
        isloading = false;
      });
    }
  }

  Future<bool> _back() async {
    await GoogleSignIn().signOut();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _back,
      child: SafeArea(
        child: Scaffold(
          key: _scaffodkey,
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
              onPressed: () async {
                Get.back();
                await GoogleSignIn().signOut();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: isloading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                          key: _formkey,
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            width: 350,
                            child: Column(
                              children: [
                                Text(
                                  "Phone Verification",
                                  style: TextStyle(fontSize: 24),
                                ),
                                Image.asset(
                                  'asset/images/phone.png',
                                ),
                                TextFormField(
                                  controller: phcontroller,
                                  validator: (val) => val!.length == 10
                                      ? null
                                      : "Enter Phone Number",
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                        Icons.phone_android_rounded,
                                        color: Colors.black87),
                                    suffixIcon: GestureDetector(
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onTap: phoneverify,
                                    ),
                                    contentPadding: EdgeInsets.all(20),
                                    hintText:
                                        "Enter your 10 digit phone number",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(width: .6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.black),
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
          ),
        ),
      ),
    );
  }
}
