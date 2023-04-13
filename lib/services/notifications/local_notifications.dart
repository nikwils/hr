import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:hr/mvvm/data/models/detail/detail_event_model.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const androidInitialize = AndroidInitializationSettings('mipmap/ic_launcher');

const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
  requestSoundPermission: true,
  requestBadgePermission: true,
  requestAlertPermission: true,
);

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'you_can_name_it_whatever1',
  'channel_name',
  playSound: true,
  importance: Importance.max,
  priority: Priority.high,
  enableVibration: true,
);

class LocalNotifications {
  LocalNotifications() {
    initialize();
  }
  Future initialize() async {
    const initializationsSettings = InitializationSettings(
      android: androidInitialize,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  }

  notificationDetails() {
    return const NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );
  }

  Future showNotification(
      {final id = 0,
      required String title,
      required String body,
      final payload,
      required FlutterLocalNotificationsPlugin fln}) async {
    fln.show(0, title, body, await notificationDetails());
  }

  callLocalNotification(bool value, DetailEventModel event) {
    if (value) {
      showNotification(
        title: 'global.local_notifications.subscribe.title'
            .tr(args: [event.title]),
        body: 'global.local_notifications.subscribe.body'
            .tr(args: [event.address ?? 'аэропорт Домодедово']),
        fln: flutterLocalNotificationsPlugin,
      );
    } else {
      showNotification(
        title: 'global.local_notifications.cancel_subscribe.title'
            .tr(args: [event.title]),
        body: 'global.local_notifications.cancel_subscribe.body'.tr(),
        fln: flutterLocalNotificationsPlugin,
      );
    }
  }
}
