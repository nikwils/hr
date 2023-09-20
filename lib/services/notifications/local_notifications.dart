import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:hr_events/mvvm/data/models/detail/detail_event_model.dart';
import 'package:hr_events/mvvm/screens/event/event_view.dart';
import 'package:hr_events/services/context_service.dart';
import 'package:hr_events/services/theme/theme_manager.dart';

//указывается ссылка на иконку drawable, которая показывается на локальном расширенном уведомлении, иконка должна быть с прозрачным фоном
//иначе белое фото
const androidInitialize = AndroidInitializationSettings('ic_notification');

const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
  requestSoundPermission: true,
  requestBadgePermission: true,
  requestAlertPermission: true,
);

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
  'high_importance_channel',
  'Важные уведомления',
  importance: Importance.max,
  priority: Priority.high,
  color: ThemeManager.mainColor,
  //Перебивает иконку, которая androidInitialize
  icon: 'ic_notification',
);

class LocalNotifications {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  LocalNotifications() {
    initialize();
  }
  Future initialize() async {
    const initializationsSettings = InitializationSettings(
      android: androidInitialize,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      //onDidReceiveNotificationResponse - позволяет реализовать клик на локальное уведомление
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        int? idNotification = details.id;
        if (details.payload != null &&
            details.payload != '' &&
            idNotification != null) {
          List<String> payloadData = details.payload!.split(' ');
          int idEvent = int.tryParse(payloadData.first)!;
          String titleEvent = payloadData.last;

          flutterLocalNotificationsPlugin.cancel(idNotification);

          navigationLocalNotifications(idEvent, titleEvent);
        }
      },
    );
  }

  void navigationLocalNotifications(int idEvent, String titleEvent) {
    String eventPath = '/event';
    bool eventPageOpen = false;

    ContextService.navigatorKey.currentState?.popUntil((route) {
      if (route.settings.name == eventPath) {
        eventPageOpen = true;
      }
      return true;
    });

    BuildContext? context = ContextService.navigatorKey.currentContext;

    if (context == null) return;

    if (eventPageOpen) {
      Navigator.of(context).pushReplacementNamed(EventView.routeName,
          arguments: {'id': idEvent, 'title': titleEvent});
    } else {
      Navigator.of(context).pushNamed(EventView.routeName,
          arguments: {'id': idEvent, 'title': titleEvent});
    }
  }

  static notificationDetails() {
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

  void callLocalNotification(value, DetailEventModel event) {
    if (value == null) {
      showNotification(
        title: 'global.local_notifications.subscribe_error.title'
            .tr(args: [event.title]),
        body: 'global.local_notifications.subscribe_error.body'.tr(),
        fln: flutterLocalNotificationsPlugin,
      );
    } else if (value) {
      showNotification(
        title: 'global.local_notifications.subscribe.title'
            .tr(args: [event.title]),
        body: 'global.local_notifications.subscribe.body'
            .tr(args: [event.location ?? '']),
        fln: flutterLocalNotificationsPlugin,
      );
    } else if (!value) {
      showNotification(
        title: 'global.local_notifications.cancel_subscribe.title'
            .tr(args: [event.title]),
        body: 'global.local_notifications.cancel_subscribe.body'.tr(),
        fln: flutterLocalNotificationsPlugin,
      );
    }
  }
}
