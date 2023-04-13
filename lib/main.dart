import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr/app_settings.dart';
import 'package:hr/mvvm/screens/events/events_view.dart';
import 'package:hr/mvvm/screens/routes.dart';
import 'package:hr/services/context_service.dart';
import 'package:hr/services/device_service.dart';
import 'package:hr/services/notifications/notifications_firebase_service.dart';
import 'package:hr/services/theme/theme_manager.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  //NOTE: обходим сертификат только на тесте
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  WidgetsFlutterBinding.ensureInitialized();
  //TODO: проверить старт без интернета, загрузится ли приложение?
  //Написать обработку ошибки, если пользователь без интернета
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  await EasyLocalization.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(
      FirebaseMessagingService.firebaseMessagingBackgroundHandler);

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('ru', 'RU')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ru', 'RU'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DeviceService().isAndroid ? const MyAppAndroid() : const MyAppIOS();
  }
}

class MyAppAndroid extends StatelessWidget {
  const MyAppAndroid({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ContextService.navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: AppSettings.myAppTitle,
      theme: ThemeManager().getThemeDataAndroid,
      home: const EventsView(),
      routes: Routes.routesMap,
    );
  }
}

class MyAppIOS extends StatelessWidget {
  const MyAppIOS({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorKey: ContextService.navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: AppSettings.myAppTitle,
      theme: ThemeManager().getThemeDataIOS,
      home: const EventsView(),
      routes: Routes.routesMap,
    );
  }
}
