import 'dart:io';

import 'package:app/models/userAccount.dart';
import 'package:app/views/Dashboard.dart' as sign;
import 'package:app/views/Dashboard.dart';
import 'package:app/views/Maps.dart';
import 'package:app/views/TrailPage.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'package:app/Data/accountProvider.dart';
import 'package:app/Data/image.dart';
import 'package:app/views/LocationPermission.dart';
import 'package:app/views/Signin.dart';
import 'package:app/views/Signup.dart';
import 'package:app/views/number_verify.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:location/location.dart' as loc;

class Welcome extends StatefulWidget {
  final FirebaseApp app;
  Welcome({required this.app});
  @override
  _WelcomeState createState() => _WelcomeState(app: app);
}

class _WelcomeState extends State<Welcome> {
  bool isloading = false;
  FirebaseApp app;
  UserCredential? userCredential;
  late User user;
  var result;
  _WelcomeState({required this.app});
  String? username;
  String? email;
  String? image;
  String? emph;
  loc.Location location = loc.Location();
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      setState(() {
        isloading = true;
      });

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("Credentials: $credential");
      print(
          "googleAuth.accessToken:${googleAuth.accessToken} googleAuth.idToken: ${googleAuth.idToken},");
      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      user = userCredential!.user!;
      try {
        print('Enter database');
        final DatabaseReference db = FirebaseDatabase(app: app).reference();

        await db.child('Users').child(user.uid).get().then(
              (DataSnapshot? datasnapshot) => print(
                result = datasnapshot!.value,
              ),
            );
        username = result!['Username'];
        email = result!['Email'];
        ph = result!['Phone'];
        image = result!['Image'];
        emph = result['emph'];
        print("Account details==$username ,$email,$image,$ph,$emph");

        bool cacheimage = await File(image!).exists();
        print("cache_image:$cacheimage");
        if (cacheimage) {
          Get.snackbar(
              "Account details", "Getting account details please await",
              snackPosition: SnackPosition.BOTTOM);
          Provider.of<ImageData>(context, listen: false)
              .updateimage(File(image!));
          print("Image is given $image");
        } else {
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('Users_profile')
              .child('/${user.uid}/${user.uid}');
          String url = await ref.getDownloadURL();
          print("url:->$url");
          Dio newimage = Dio();
          String savePath =
              Directory.systemTemp.path + '/' + user.uid + "_profile_google";
          await newimage.download(url, savePath,
              options: Options(responseType: ResponseType.bytes));
          db.child('Users').child(user.uid).update({"Image": savePath});
          Provider.of<ImageData>(context, listen: false)
              .updateimage(File(savePath));
          image = savePath;
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("Uid", user.uid);
        prefs.setString("Username", username!);
        prefs.setString("Email", email!);
        prefs.setString("Ph", ph!);
        prefs.setString("Image", image!);
        prefs.setString("emph", emph!);
        UserAccount userAccData = UserAccount(
            Email: email!,
            Image: image,
            emph: emph!,
            Ph: ph,
            Uid: user.uid,
            Username: username!);
        Provider.of<AccountProvider>(context, listen: false)
            .updateuseraccount(userAccData);
        if (await permissions.Permission.locationWhenInUse.isGranted ||
            await permissions.Permission.locationWhenInUse.isLimited ||
            await permissions.Permission.location.isGranted ||
            await permissions.Permission.location.isLimited) {
          _checkGps();
        } else {
          Get.offAll(LocationPermissoin(app: app));
        }
        setState(() {
          isloading = true;
        });
      } on PlatformException catch (e) {
        isloading = false;
        print("weak network");
        Get.snackbar(
          " Google Sign In ",
          "Error Occured during sign in internet connection strength is weak",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 4),
        );
        print("errors=$e");
      } catch (e) {
        print('Login $user');
        print(e);
        setState(() {
          isloading = false;
        });

        Get.to(
          Numverify(user: user, app: app),
        );
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      print("Error while creating account");
    }
  }

  void _checkGps() async {
    bool locationServices = await location.serviceEnabled();
    print("val:$locationServices");
    if (!locationServices) {
      Get.snackbar("Location Service", "Location service should be enable ");
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
        body: SingleChildScrollView(
          child: LayoutBuilder(builder: (ctx, constraint) {
            return Container(
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
                  SizedBox(height: 20),
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
                  ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context)
                          .unfocus(); //to hide the keyboard by unfocusing on textformfield
                      Get.to(SignIn(app: app));
                    },
                    child: Text('Sign In',
                        style: GoogleFonts.ubuntu(
                            color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      onPrimary: Colors.white,
                      primary: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  SizedBox(
                    height: 24,
                    width: double.infinity,
                    child: Center(
                      child: Stack(
                        children: [
                          Center(
                            child: Container(
                              height: 1,
                              width: MediaQuery.of(context).size.width * 0.65,
                              color: Colors.black,
                            ),
                          ),
                          Center(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              child: Text(
                                ' Or ',
                                style: TextStyle(backgroundColor: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      primary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    ),
                    label: Text('Sign in with Google',
                        style: GoogleFonts.ubuntu(
                            color: Colors.black, fontSize: 16)),
                    icon: Image.asset(
                      'asset/images/google_logo.png',
                      width: 35,
                    ),
                    onPressed: () async {
                      signInWithGoogle();
                    },
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an Account ?',
                          style: GoogleFonts.roboto(
                              color: Colors.black, fontSize: 16)),
                      GestureDetector(
                        onTap: () {
                          Get.off(SignUp(app: app));
                        },
                        child: Text(' Sign Up',
                            style: GoogleFonts.roboto(
                                color: Colors.blue, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
