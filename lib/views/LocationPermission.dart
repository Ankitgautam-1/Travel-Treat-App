import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:open_apps_settings/open_apps_settings.dart';
import 'package:open_apps_settings/settings_enum.dart';
import 'package:app/views/Maps.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:location/location.dart' as loc;

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
    final PermissionStatus permissionRequestResult = await LocationPermissions()
        .requestPermissions(permissionLevel: permissionLevel);
    print('Here ans:-$permissionRequestResult');
    if (permissionRequestResult == PermissionStatus.denied ||
        permissionRequestResult == PermissionStatus.restricted ||
        permissionRequestResult == PermissionStatus.unknown) {
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
        body: Container(
          height: MediaQuery.of(context).size.height * 0.80,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Location Permission",
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 35,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Our App Privacy Notice describes the information we collect, how it is used and shared, and your choices regarding this information. \n \nThis policy applies to any users of the services of our app or its affiliates anywhere in the world, and to anyone else who contacts Us or otherwise submits information to App, unless noted in the Privacy Notice.",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  await requestPermission(_permissionLevel);
                },
                child: Text('Give Permission'),
              ),
              SizedBox(
                height: 35,
              ),
              ElevatedButton(
                onPressed: () async {
                  await OpenAppsSettings.openAppsSettings(
                      settingsCode: SettingsCode.APP_SETTINGS,
                      onCompletion: () async {
                        if (await permissions.Permission.locationWhenInUse.isGranted ||
                            await permissions
                                .Permission.locationWhenInUse.isLimited ||
                            await permissions.Permission.location.isGranted ||
                            await permissions.Permission.location.isLimited) {
                          _checkGps();
                        }
                      });
                },
                child: Text('Open Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
