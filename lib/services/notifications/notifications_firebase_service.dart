import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:hr_events/mvvm/screens/event/event_view.dart';
import 'package:hr_events/mvvm/screens/events/events_view.dart';
import 'package:hr_events/services/api/api_controller_service.dart';
import 'package:hr_events/services/api/api_service.dart';
import 'package:hr_events/services/context_service.dart';
import 'package:hr_events/services/device_service.dart';
import 'package:hr_events/services/exception_handlers/exception_handlers.dart';
import 'package:hr_events/services/notifications/local_notifications.dart';
import 'package:hr_events/services/theme/theme_manager.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('firebaseMessagingBackgroundHandler');
  }
  await Firebase.initializeApp();
}

class FirebaseMessagingService {
  static final _singleton = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _singleton;
  FirebaseMessagingService._internal() {
    initializeFirebase();
  }

  void initializeFirebase() async {
    await setupFlutterNotifications();
    await _requestPermission();
    await _getToken();
    await _initInfo();
  }

  late AndroidNotificationChannel channel;
  bool isFlutterLocalNotificationsInitialized = false;

//отображение уведомлений при фоновом или закрытом приложении Андройд
  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      ledColor: ThemeManager.mainColor,
    );

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        LocalNotifications().flutterLocalNotificationsPlugin;
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    //показывает уведомление на андройде при фоновом или закрытом состоянии приложения
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    isFlutterLocalNotificationsInitialized = true;
  }

  final _messaging = FirebaseMessaging.instance;

//запросить разрешение на получение FCM у пользователя для IOS. Для Android не требуется
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      } //Пользователь предоставил разрешение
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      } //Пользователь предоставил временное разрешение
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      } //Пользователь отклонил или не принял разрешение
    }
  }

  Future<void> _getToken() async {
    String? token = await _messaging.getToken();

    final response = await ApiService()
        .post(controller: ApiControllerService.pushToken, body: {
      'pushId': token ?? '',
      'UID': DeviceService().deviceUID,
      'os': DeviceService().isAndroid ? 'android' : 'ios',
    });

    if (response == null) throw Exception();

    if (response.statusCode == 200) {
    } else {
      throw Exception().toString();
    }

    if (kDebugMode) {
      print('Registration Token=$token');
    }
  }

  Future<void> _initInfo() async {
    //уведомление переднего плана на Andoid, приложение открыто
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        LocalNotifications().flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              LocalNotifications.notificationDetails(),
              payload: '${message.data["eventId"]} ${notification.title}',
            );
      }
    });
    //уведомление переднего плана на IOS, приложение открыто
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Требуется для отображения всплывающего уведомления
      badge: true,
      sound: true,
    );
  }

  Future<void> setupInteractedMessage() async {
    //Обработка нажатия на уведомление, если приложение закрыто, на обоих ОС
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    //Обработка нажатия на уведомление, если приложение в фоновом режиме, на обоих ОС
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  static void _handleMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;

    try {
      if (message.data["eventId"] != null && message.data["eventId"] != '') {
        int idEvent = int.tryParse(message.data["eventId"])!;
        String titleEvent = notification?.title ?? '';
        Navigator.of(ContextService.navigatorKey.currentContext!).pushNamed(
            EventView.routeName,
            arguments: {'id': idEvent, 'title': titleEvent});
      } else {
        Navigator.of(ContextService.navigatorKey.currentContext!)
            .pushNamed(EventsView.routeName);
      }
    } catch (e) {
      ExceptionHandlers().getExceptionString(e);
    }
  }
}
