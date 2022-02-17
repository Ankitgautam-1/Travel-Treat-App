import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  String? selectNotification(String payload) {}
  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        new AndroidInitializationSettings('mipmap/notify');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await FlutterLocalNotificationsPlugin().initialize(initializationSettings,
        onSelectNotification: (val) {
      print('notification clicked:$val');
    });
  }
}
