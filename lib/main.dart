import 'dart:io';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:app/Data/DirectionProvider.dart';
import 'package:app/Data/destinationmarkers.dart';
import 'package:app/Data/image.dart';
import 'package:app/Data/pickuploc.dart';
import 'package:app/Data/userData.dart';
import 'package:app/models/userAccount.dart';
import 'package:app/views/Dashboard.dart';
import 'package:app/views/LocationPermission.dart';
import 'package:app/views/Signin.dart';
import 'package:app/views/TrailPage.dart';
import 'package:app/views/Welcome.dart';
import 'package:app/views/introduction_page.dart';
import 'package:app/views/test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Data/accountProvider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:location/location.dart' as loc;

bool haspermission = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp();

  print("App:$app");
  haspermission = await permissions.Permission.locationWhenInUse.isGranted ||
      await permissions.Permission.locationWhenInUse.isLimited ||
      await permissions.Permission.location.isGranted ||
      await permissions.Permission.location.isLimited;
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  VisualDensity.adaptivePlatformDensity;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserData>(
          create: (context) => UserData(),
        ),
        ChangeNotifierProvider<AccountProvider>(
          create: (context) => AccountProvider(),
        ),
        ChangeNotifierProvider<ImageData>(
          create: (context) => ImageData(),
        ),
        ChangeNotifierProvider<DestinationMarkers>(
          create: (context) => DestinationMarkers(),
        ),
        ChangeNotifierProvider<PickupMarkers>(
          create: (context) => PickupMarkers(),
        ),
        ChangeNotifierProvider<DirectionsProvider>(
          create: (context) => DirectionsProvider(),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Ubuntu',
        ),
        home: SafeArea(
          child: MyApp(app: app),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final FirebaseApp app;
  MyApp({required this.app});
  @override
  _MyAppState createState() => _MyAppState(app: app);
}

class _MyAppState extends State<MyApp> {
  var uid, image, username, ph, email, emph;
  bool intro = true;
  FirebaseApp app;
  loc.Location location = loc.Location();
  bool locationService = false;
  _MyAppState({required this.app});
  @override
  void initState() {
    checkonbord();
    super.initState();
    checkuid();
  }

  void checkonbord() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? val = prefs.getBool("IntroPage");
    if (val != null) {
      intro = val;
    }
  }

  void checkuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('Uid') != null) {
      uid = prefs.getString('Uid');
      username = prefs.getString('Username');
      email = prefs.getString('Email');
      image = prefs.getString('Image');
      ph = prefs.getString('Ph');
      emph = prefs.getString("emph");
      Provider.of<ImageData>(context, listen: false).updateimage(File(image));
      UserAccount userAccData = UserAccount(
          Email: email,
          Image: image ?? "",
          Ph: ph,
          Uid: uid,
          emph: emph,
          Username: username);
      Provider.of<AccountProvider>(context, listen: false)
          .updateuseraccount(userAccData);
      if (image == "") {
        try {
          firebase_storage.Reference ref = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('Users_profile')
              .child('/$uid/$uid');
          String imageurl = await ref.getDownloadURL();
          print("image url is :>$imageurl");
        } catch (e) {}
      } else {
        print("Image is availabel");
      }
      _checkGps();
    } else {
      uid = "";
    }

    setState(() {
      uid = uid;
    });
  }

  void _checkGps() async {
    bool locationServices = await location.serviceEnabled();
    print("val:$locationServices");
    if (!locationServices) {
      Future.delayed(
        const Duration(seconds: 4),
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
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 5500,
      splash: 'asset/Animation/cab-animation.gif',
      backgroundColor: Colors.white,
      nextScreen: uid == ""
          ? intro
              ? OnBoardingPage(app: app)
              : Welcome(
                  app:
                      app) //!!Change here to Welcome after trailpage for sign in is over
          : haspermission && locationService
              ? Dashboard(app: app)
              : LocationPermissoin(app: app),
      splashIconSize: 350,
    );
  }
}

/*TrailPage(
                  app:
                      app)  */
