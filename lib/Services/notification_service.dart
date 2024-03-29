// Imports:

// Dart Imports
import 'dart:io';

// Flutter Imports
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Firebase Imports
import 'package:firebase_messaging/firebase_messaging.dart';

/// Foreground Notification only shows when user is in the app
class ForegroundNotifyService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void _initLocalNotifications(RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      // handle interaction when app is active for android
      _handleMessage(payload, message);
    });
  }

  void firebaseInit() {
    FirebaseMessaging.instance.subscribeToTopic("TestNotify");

    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      debugPrint("Title: ${notification!.title}");
      debugPrint("Body: ${notification.body}");
      debugPrint("Count: ${android!.count}");
      debugPrint("data: ${message.data.toString()}");

      if (Platform.isIOS) {
        _forgroundMessage();
      }

      if (Platform.isAndroid) {
        _initLocalNotifications(message);
        _showNotification(message);
      }
    });
  }

  void requestNotificationPermissions() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("user granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("user granted provisional permission");
    } else {
      debugPrint("user denied permissions");
    }
  }

  Future<String> getDeviceToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      event.toString();
      debugPrint('refresh');
    });
  }

  // function to show visible notification when app is active
  Future<void> _showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      // Needs to be max, or else it will be ignored
      importance: Importance.max,
      showBadge: true,
      playSound: true,
      //sound: const RawResourceAndroidNotificationSound('jetsons_doorbell')
    );

    // How it should look
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            ticker: 'ticker',
            sound: channel.sound
            //     sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
            //  icon: largeIconPath
            );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);
    var ext = '';

    for (MapEntry<String, dynamic> item in message.data.entries) {
      ext += item.value as String;
      ext += '|';
    }
    debugPrint('values $ext');

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification?.title.toString(),
          message.notification?.body.toString(),
          notificationDetails,
          payload: ext);
    });
  }

  void _handleMessage(NotificationResponse payload, RemoteMessage message) {
    //Do something in the app when the notification is tapped
    debugPrint(
        'handlemesage: ${message.messageId.toString()} Payload: ${payload.payload}');
  }

  Future _forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
