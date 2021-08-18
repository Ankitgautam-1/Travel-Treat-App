import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'package:app/Data/accountProvider.dart';
import 'package:app/Data/image.dart';
import 'package:app/models/userAccount.dart';
import 'package:app/views/Email_verify.dart';
import 'package:app/views/LocationPermission.dart';
import 'package:app/views/Maps.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:location/location.dart' as loc;

class Prc extends StatefulWidget {
  final FirebaseApp app;
  final List<dynamic> data;
  final bool isgoogle;
  Prc({required this.data, required this.isgoogle, required this.app});
  @override
  _PrcState createState() =>
      _PrcState(data: data, isgoogle: isgoogle, app: app);
}

class _PrcState extends State<Prc> {
  List<dynamic> data;
  FirebaseApp app;
  bool isgoogle;
  _PrcState({required this.data, required this.isgoogle, required this.app});
  TextEditingController _1st = TextEditingController();
  TextEditingController _2nd = TextEditingController();
  TextEditingController _3rd = TextEditingController();
  TextEditingController _4th = TextEditingController();
  TextEditingController _5th = TextEditingController();
  TextEditingController _6th = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  String _otp = "";
  String verificationId = "";
  User? user;
  String _ph = "";
  loc.Location location = loc.Location();
  @override
  void initState() {
    sendotp();
    super.initState();
  }

  Future sendotp() async {
    _ph = "+91" + data[2];
    if (isgoogle) {
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _ph,
          // ignore: non_constant_identifier_names
          verificationCompleted: (PhoneAuthCredential) async {},
          verificationFailed: (FirebaseAuthException e) async {
            if (e.code == 'invalid-phone-number') {
              Get.snackbar(
                  "Phone verification ", "Error occure while verification $e");
            }
            Get.snackbar(
                "Phone verification ", "Error occure while verification $e");
          },
          timeout: Duration(seconds: 100),
          codeSent: (verificationId, resendingToken) async {
            print("Otp is send ");
            Get.snackbar(
              "",
              "",
              titleText: Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              messageText: Text(
                'A OTP Message is send to your Mobile number $_ph is verify it',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            );
            this.verificationId = verificationId;
          },
          codeAutoRetrievalTimeout: (String verificationId) {});
    } else {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _ph,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        timeout: const Duration(seconds: 100),
        verificationFailed: (FirebaseAuthException e) async {
          if (e.code == 'invalid-phone-number') {
            Get.snackbar("Phone Verfication", "Invalid phone number");
            print('The provided phone number is not valid.');
          } else if (e.code == "FirebaseTooManyRequestsException") {
            Get.snackbar("Phone Verfication", "SMS Services Error");
          }
          print(e);
        },
        codeSent: (verificationId, resendingToken) async {
          print("Otp is send ");
          Get.snackbar("", "",
              titleText: Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              messageText: Text(
                'A OTP Message is send to your Mobile number $_ph is verify it',
                style: TextStyle(
                  fontSize: 11,
                ),
              ));
          this.verificationId = verificationId;
          print('$verificationId here it\'s');
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      print(data[2]);
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> verify(String otp_code) async {
    if (isgoogle) {
      print(data);
      var uid = auth.currentUser!.uid;
      print(uid);
      print(" Verfication :$verificationId");
      // ignore: unused_local_variable
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp_code);
      try {
        // auth.signInWithCredential(
        //     phoneAuthCredential); //by commneting this line you can add same ph-number
        try {
          print("1st");
          Dio newimage = Dio();
          String savePath =
              Directory.systemTemp.path + '/' + uid + "_profile_google";
          print("path =>$savePath");
          await newimage.download(
            data[3],
            savePath,
            options: Options(responseType: ResponseType.bytes),
          );
          print("2nd");
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('Users_profile')
              .child('/$uid/$uid');

          print("Uploading image");
          await ref.putFile(File(savePath));
          print('Uploaded image');
          Provider.of<ImageData>(context, listen: false)
              .updateimage(File(savePath));
          print("3rd");
          final DatabaseReference db = FirebaseDatabase(app: app).reference();
          print("The db :$db");
          try {
            await db.child('Users').child(uid).set(
              {
                "Username": "${data[0]}",
                "Email": "${data[1]}",
                "Phone": "${data[2]}",
                "Image": "$savePath",
              },
            );
            UserAccount userAccData = UserAccount(
                Email: data[1],
                Image: savePath,
                Ph: data[2],
                Uid: uid,
                Username: data[0]);
            Provider.of<AccountProvider>(context, listen: false)
                .updateuseraccount(userAccData);

            SharedPreferences prefs = await SharedPreferences.getInstance();

            prefs.setString("Username", data[0]);
            prefs.setString("Email", data[1]);
            prefs.setString("Ph", data[2]);
            prefs.setString("Image", savePath);
            prefs.setString("Uid", uid);
            if (await permissions.Permission.locationWhenInUse.isGranted ||
                await permissions.Permission.locationWhenInUse.isLimited ||
                await permissions.Permission.location.isGranted ||
                await permissions.Permission.location.isLimited) {
              _checkGps();
            } else {
              Get.offAll(LocationPermissoin(app: app));
            }
          } catch (e) {
            print('Error $e');
          }
        } catch (e) {
          Get.snackbar(
              "Account creation", "Error occured while creating account $e");
        }
      } catch (e) {
        Get.snackbar(
            "Phone Authentication", "Error occured while creating account $e");
      }
    } else {
      try {
        print(' ver :$verificationId');
        PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: otp_code);
        print('Signed In');
        try {
          await auth.createUserWithEmailAndPassword(
              email: data[1], password: data[3]);
          user = auth.currentUser;
          user!.sendEmailVerification();

          Get.to(
            EmailVerify(data: data, app: app),
          );
        } catch (e) {
          Get.snackbar(
            "Phone verification",
            "Error occured $e",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        print("Error while Signin with phone ");
      }
    }
  }

  void _checkGps() async {
    bool locationServices = await location.serviceEnabled();
    print("val:$locationServices");
    if (!locationServices) {
      Future.delayed(
        Duration(seconds: 3),
        () async {
          await OpenAppsSettings.openAppsSettings(
            settingsCode: SettingsCode.LOCATION,
            onCompletion: () async {
              if (await location.serviceEnabled()) {
                Get.offAll(Maps(app: app));
              } else {
                Get.offAll(LocationPermissoin(app: app));
              }
            },
          );
        },
      );
    } else {
      Get.offAll(Maps(app: app));
    }
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
            onPressed: () async {
              Navigator.pop(context);
              try {
                await auth.signOut();
              } catch (e) {}
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 35,
              ),
              Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 35,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Please don\'t share your OTP',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Image.asset(
                'asset/images/email_verification_bg.png',
                height: 300,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _1st,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 1.4),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _2nd,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _3rd,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _4th,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _5th,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _6th,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 90, vertical: 12),
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                onPressed: () async {
                  FocusScope.of(context)
                      .unfocus(); //to hide the keyboard by unfocusing on textformfield
                  _otp = _1st.text +
                      _2nd.text +
                      _3rd.text +
                      _4th.text +
                      _5th.text +
                      _6th.text;
                  print("Your otp is  $_otp");
                  await verify(_otp);
                },
                child: Text(
                  'Verify OTP',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
