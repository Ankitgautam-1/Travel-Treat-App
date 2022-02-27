import 'package:app/views/Maps.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:location/location.dart' as loc;
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class LocationPermissoin extends StatefulWidget {
  final FirebaseApp app;
  LocationPermissoin({required this.app});

  @override
  _LocationPermissoinState createState() => _LocationPermissoinState(app: app);
}

class _LocationPermissoinState extends State<LocationPermissoin> {
  FirebaseApp app;
  _LocationPermissoinState({required this.app});
  loc.Location location = loc.Location();
  final LocationPermissionLevel _permissionLevel =
      LocationPermissionLevel.locationAlways;

  Future<void> requestPermission(
      LocationPermissionLevel permissionLevel) async {
    Map<dynamic, dynamic> status = await [
      permission.Permission.location,
    ].request();

    if (status.values.contains(false)) {
      print('status: ${status.values}');
    } else {
      _checkGps();
    }
  }

  void _checkGps() async {
    bool locationServices = await location.serviceEnabled();
    print("val:$locationServices");
    if (!locationServices) {
      Get.snackbar("Location Permission",
          "Location service is not enabled visting settings ");
      Future.delayed(
        Duration(seconds: 4),
        () async {
          await OpenAppsSettings.openAppsSettings(
            settingsCode: SettingsCode.LOCATION,
            onCompletion: () async {
              if (await location.serviceEnabled()) {
                Get.offAll(Maps(app: app));
              } else {
                Get.snackbar(
                  "Location Permission ",
                  "Location service is not enabled ",
                  duration: Duration(seconds: 4),
                );
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
        body: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Location Permission",
                          style: GoogleFonts.openSans(
                              fontSize: 30, fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Image.asset(
                            'asset/images/location_permission.jpg',
                            width: MediaQuery.of(context).size.width * 0.9,
                          ),
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.location_on_rounded),
                          label: Text(
                            "Give Permission",
                            style: GoogleFonts.openSans(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                          style: ElevatedButton.styleFrom(
                            onPrimary: Color.fromRGBO(28, 18, 140, 1),
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                width: 1,
                                color: Color.fromRGBO(28, 18, 140, 1),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            await requestPermission(_permissionLevel);
                          },
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: TextButton.icon(
                            label: Text(
                              "Open Settings",
                              style: GoogleFonts.openSans(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            icon: Icon(CupertinoIcons.settings),
                            style: ElevatedButton.styleFrom(
                                onPrimary: Colors.white,
                                primary: Color.fromRGBO(28, 18, 140, 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () async {
                              await OpenAppsSettings.openAppsSettings(
                                  settingsCode: SettingsCode.APP_SETTINGS,
                                  onCompletion: () async {
                                    if (await permissions.Permission.locationWhenInUse.isGranted ||
                                        await permissions.Permission
                                            .locationWhenInUse.isLimited ||
                                        await permissions
                                            .Permission.location.isGranted ||
                                        await permissions
                                            .Permission.location.isLimited) {
                                      _checkGps();
                                    }
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
