import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hr/mvvm/screens/event/event_view.dart';
import 'package:hr/services/api/api_controller_service.dart';
import 'package:hr/services/api/api_service.dart';
import 'package:hr/services/context_service.dart';
import 'package:hr/services/device_service.dart';
import 'package:hr/services/exception_handlers/exception_handlers.dart';
import 'package:hr/services/notifications/local_notifications.dart';

class FirebaseMessagingService {
  static final _singleton = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _singleton;
  FirebaseMessagingService._internal() {
    requestPermission();
    getToken();
    initInfo();
  }

  static final _messaging = FirebaseMessaging.instance;

  requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  getToken() async {
    String? token = await _messaging.getToken();

    try {
      final response = await ApiService()
          .post(controller: ApiControllerService.pushToken, body: {
        'pushId': DeviceService().deviceUID,
        'os': DeviceService().isAndroid ? 'android' : 'ios',
      });

      if (response == null) throw Exception();

      if (response.statusCode == 200) {
      } else {
        throw Exception().toString();
      }
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }

    if (kDebugMode) {
      print('Registration Token=$token');
    }
  }

  initInfo() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          LocalNotifications().notificationDetails(),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      try {
        if (message.data["id"] != null) {
          int eventId = int.tryParse(message.data["id"])!;
          Navigator.of(ContextService.navigatorKey.currentContext!)
              .pushNamed(EventView.routeName, arguments: eventId);
        }
      } on ExceptionHandlers catch (e) {
        e.getExceptionString(e);
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('firebaseMessagingBackgroundHandler');
    await Firebase.initializeApp();
  }
}
