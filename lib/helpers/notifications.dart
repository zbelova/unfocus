import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationService {
  NotificationService();

  final localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      //onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await localNotifications.initialize(
      initializationSettings,
    );
    localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
  }


  // Future showFocusNotification(int seconds) async {
  //   int id = 1;
  //   String title = 'Time to focus!';
  //   String body = 'Keep focused on your goals!';
  //
  //   // tz.TZDateTime date = tz.TZDateTime.now(tz.local);
  //   // tz.TZDateTime nextDay = date.add(const Duration(days: 1));
  //   // tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, nextDay.year, nextDay.month, nextDay.day, 8, 0, 3);
  //   // DateTime nowTime = DateTime.now();
  //   // DateTime focusTime= nowTime.add(Duration(seconds: seconds));
  //
  //   tz.TZDateTime date = tz.TZDateTime.now(tz.local);
  //   tz.TZDateTime focusTime= date.add(Duration(seconds: seconds));
  //
  //   final platformChannelSpecifics = await notificationDetails('focus', 'channelFocus');
  //
  //   await localNotifications.zonedSchedule(
  //     id,
  //     title,
  //     body,
  //     focusTime,
  //     platformChannelSpecifics,
  //     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, //To show notification even when the app is closed
  //   );
  //
  //  // var active = localNotifications.getActiveNotifications().then((value) => print(value));
  // }

  Future showImmediateNotification() async {
    const androidDetails = AndroidNotificationDetails(
      "ID",
      "Time to focus!",
      importance: Importance.high,
      channelDescription: "Keep focused on your goals",

    );

    const iosDetails = DarwinNotificationDetails();
    const generalNotificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotifications.show(0, "Time to focus!", "Keep focused on your goals", generalNotificationDetails);
  }
}

Future<NotificationDetails> notificationDetails(String id, String name) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    // 'channel id',
    // 'channel name',
    id,
    name,
    // groupKey: 'com.example.flutter_push_notifications',
    // channelDescription: 'channel description',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    ticker: 'ticker',

    color: const Color(0xff2196f3),
  );

  DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
    threadIdentifier: "thread1",
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

  return platformChannelSpecifics;
}
