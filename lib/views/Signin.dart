import 'dart:io';
import 'package:app/views/Dashboard.dart';
import 'package:app/views/Maps.dart';
import 'package:app/views/number_verify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/Data/accountProvider.dart';
import 'package:app/Data/image.dart';
import 'package:app/models/userAccount.dart';
import 'package:app/views/LocationPermission.dart';
import 'package:app/views/Signup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:location/location.dart' as loc;
import 'package:loader_overlay/loader_overlay.dart';

class SignIn extends StatefulWidget {
  final FirebaseApp app;
  SignIn({required this.app});
  @override
  _SignInState createState() => _SignInState(app: app);
}

class _SignInState extends State<SignIn> {
  FirebaseApp app;
  String? username, email, ph, image = "", emph = "", token = "", rating = "";
  _SignInState({required this.app});
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<dynamic, dynamic>? result;
  bool _obscure = true;
  bool isloading = false;
  String ImageUrl = "";
  final _firestore = FirebaseFirestore.instance;
  UserCredential? userCredential;
  loc.Location location = loc.Location();
  Future loginwithemail() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        context.loaderOverlay.show();
      });
      try {
        await _auth.signInWithEmailAndPassword(
            email: _email.text, password: _pass.text);

        User? user = _auth.currentUser;
        var uid = user!.uid;
        print("Uid :$uid");
        var collectionReference = _firestore.collection('Users');
        collectionReference.doc(uid).get().then((value) async {
          ImageUrl = value.data()!["Image"];

          try {
            collectionReference.doc(uid).get().then((value) async {
              username = value.data()!['Username'];
              email = value.data()!['Email'];
              ph = value.data()!['Phone'];
              image = value.data()!['Image'];
              emph = value.data()!['emph'];
              token = value.data()!['token'];
              rating = value.data()!['rating'];

              print("$username ,$email,$image,$ph");
              UserAccount userAccount = UserAccount(
                Email: email!,
                Image: image!,
                Ph: ph!,
                Uid: uid,
                emph: emph!,
                ImageUrl: ImageUrl,
                Username: username!,
                rating: rating ?? "4.5",
              );

              Provider.of<AccountProvider>(context, listen: false)
                  .updateuseraccount(userAccount);

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("Uid", user.uid);
              prefs.setString("Username", username!);
              prefs.setString("Email", email!);
              prefs.setString("Ph", ph!);
              prefs.setString("Image", image!);
              prefs.setString("emph", emph!);
              prefs.setString("rating", rating!);

              if (await permissions.Permission.locationWhenInUse.isGranted ||
                  await permissions.Permission.locationWhenInUse.isLimited ||
                  await permissions.Permission.location.isGranted ||
                  await permissions.Permission.location.isLimited) {
                _checkGps();
                setState(() {
                  context.loaderOverlay.hide();
                });
              } else {
                setState(() {
                  context.loaderOverlay.hide();
                });
                Get.offAll(LocationPermissoin(app: app));
              }
            });
          } on PlatformException catch (e) {
            Get.snackbar("Sign In ",
                "Error Occured during sign in internet connection strength is weak",
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 4));
            setState(() {
              context.loaderOverlay.hide();
            });
          } catch (e) {
            print(e);
          }
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          context.loaderOverlay.hide();
        });
        if (e.code == 'user-not-found') {
          Get.snackbar("Sign In", "Error Occured usernot found",
              snackPosition: SnackPosition.BOTTOM);
        } else if (e.code == 'wrong-password') {
          Get.snackbar("Sign In", "Error Occured invalid password",
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        setState(() {
          context.loaderOverlay.hide();
        });
        Get.snackbar("Sign In", "Error Occured $e",
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      print("Not valid");
    }
  }

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
      var user = userCredential!.user!;
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

        print("Account details==$username ,$email,$image,$ph");

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
        prefs.setString("rating", rating!);
        UserAccount userAccData = UserAccount(
          Email: email!,
          Image: image,
          Ph: ph!,
          Uid: user.uid,
          emph: emph!,
          Username: username!,
          rating: rating ?? "4.5",
        );
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
        Get.snackbar(" Google Sign In ",
            "Error Occured during sign in internet connection strength is weak",
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 4));
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
      child: LoaderOverlay(
        useDefaultLoading: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 40,
            backgroundColor: Colors.white,
            title: Text(
              'Sign In',
              style: GoogleFonts.roboto(color: Colors.black),
            ),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 25,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text("Hello,\nWelcome Back",
                        style: TextStyle(fontSize: 26, color: Colors.black)),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.10,
                  ),
                  Center(
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 320,
                            child: TextFormField(
                              controller: _email,
                              validator: (val) =>
                                  val!.isEmail ? null : "Enter valide email",
                              keyboardType: TextInputType.text,
                              style: GoogleFonts.openSans(),
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child:
                                      Icon(Icons.email, color: Colors.black87),
                                ),
                                contentPadding: EdgeInsets.all(20),
                                hintText: "Email",
                                hintStyle: GoogleFonts.roboto(
                                    color: Colors.black54, fontSize: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(width: .6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),
                          //input password
                          Container(
                            width: 320,
                            child: TextFormField(
                              obscureText: _obscure,
                              controller: _pass,
                              style: GoogleFonts.openSans(),
                              validator: (val) => val!.length > 6
                                  ? null
                                  : "password should be at least 6 charcter",
                              keyboardType: TextInputType.text,
                              cursorColor: Colors.black,
                              textInputAction: TextInputAction.send,
                              decoration: InputDecoration(
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: IconButton(
                                    icon: FaIcon(
                                      _obscure
                                          ? FontAwesomeIcons.eye
                                          : FontAwesomeIcons.eyeSlash,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscure = !_obscure;
                                      });
                                    },
                                  ),
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.vpn_key,
                                      color: Colors.black87),
                                ),
                                contentPadding: EdgeInsets.all(20),
                                hintText: "Password",
                                hintStyle: GoogleFonts.roboto(
                                    color: Colors.black54, fontSize: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(width: .6),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.black),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 20),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.blue[700],
                                    ),
                                    onPressed: () {},
                                    child: Text("Forgot Password"),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                          ),

                          ElevatedButton(
                            onPressed: () async {
                              FocusScope.of(context)
                                  .unfocus(); //to hide the keyboard by unfocusing on textformfield
                              await loginwithemail();
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
                            height: MediaQuery.of(context).size.height * 0.12,
                          ),

                          // SizedBox(
                          //   height: MediaQuery.of(context).size.height * 0.01,
                          // ),
                          // SizedBox(
                          //   height: 24,
                          //   width: double.infinity,
                          //   child: Center(
                          //     child: Stack(
                          //       children: [
                          //         Center(
                          //           child: Container(
                          //             height: 1,
                          //             width: MediaQuery.of(context).size.width *
                          //                 0.65,
                          //             color: Colors.black,
                          //           ),
                          //         ),
                          //         Center(
                          //           child: Container(
                          //             padding: const EdgeInsets.symmetric(
                          //                 horizontal: 50),
                          //             child: Text(
                          //               ' Or ',
                          //               style: TextStyle(
                          //                   backgroundColor: Colors.white),
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          // SizedBox(
                          //   height: 40,
                          // ),
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
