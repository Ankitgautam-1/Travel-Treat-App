import 'dart:async';
import 'dart:io';
import 'package:app/views/Dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'package:app/Data/accountProvider.dart';
import 'package:app/Data/image.dart';
import 'package:app/models/userAccount.dart';
import 'package:app/views/LocationPermission.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:location/location.dart' as loc;

class EmailVerify extends StatefulWidget {
  final FirebaseApp app;
  final List<dynamic> data;
  EmailVerify({required this.data, required this.app});
  @override
  _EmailVerifyState createState() => _EmailVerifyState(data: data, app: app);
}

class _EmailVerifyState extends State<EmailVerify> {
  FirebaseApp app;
  List<dynamic> data;

  _EmailVerifyState({required this.data, required this.app});
  firebase_storage.UploadTask? uploadTask;
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  bool isdisable = false;
  bool isloading = false;
  loc.Location location = loc.Location();
  @override
  void initState() {
    user = auth.currentUser;

    print(data);
    print('Checking for verification');
    timer = Timer.periodic(Duration(seconds: 4), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ImageData>(
          create: (context) => ImageData(),
        ),
      ],
      child: SafeArea(
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
                  await FirebaseAuth.instance.signOut();
                } catch (e) {}
                timer!.cancel();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
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
                isloading ? CircularProgressIndicator() : Container()
              ],
            ),
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
      final String uid = user!.uid;

      final String username = data[0];
      final String email = data[1];
      final String ph = data[2];
      final String emph = data[3];
      final dynamic profile = data[5];

      setState(() {
        isloading = true;
      });
      try {
        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('Users_profile')
            .child('/${user!.uid}/${user!.uid}');
        print("Uploading image");
        File prof = Provider.of<ImageData>(context, listen: false).image!;
        uploadTask = ref.putFile(prof);
        print('Uploaded image');
        final DatabaseReference db = FirebaseDatabase(app: app).reference();

        await db.child('Users').child(uid).set(
          {
            "Username": "$username",
            "Email": "$email",
            "Phone": "$ph",
            "Image": prof.path,
            "emph": emph,
          },
        );
        Provider.of<AccountProvider>(context, listen: false).updateuseraccount(
            UserAccount(
                Email: email,
                Image: profile,
                Ph: ph,
                Uid: uid,
                emph: emph,
                Username: username));

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("Username", username);
        prefs.setString("Email", email);
        prefs.setString("Ph", ph);
        prefs.setString("Image", prof.path);
        prefs.setString("Uid", uid);
        prefs.setString("emph", emph);
        if (await permissions.Permission.locationWhenInUse.isGranted ||
            await permissions.Permission.locationWhenInUse.isLimited ||
            await permissions.Permission.location.isGranted ||
            await permissions.Permission.location.isLimited) {
          setState(() {
            isloading = false;
          });
          _checkGps();
        } else {
          setState(() {
            isloading = false;
          });
          Get.offAll(LocationPermissoin(app: app));
        }
      } catch (e) {
        setState(() {
          isloading = false;
        });
        Get.snackbar("Account Creation Error", "Erorr Occured $e");
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
                Get.offAll(Dashboard(app: app));
              } else {
                Get.offAll(LocationPermissoin(app: app));
              }
            },
          );
        },
      );
    } else {
      Get.offAll(Dashboard(app: app));
    }
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }
}
