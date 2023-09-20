import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:hr_events/services/exception_handlers/exception_handlers.dart';

class DeviceService {
  static final _singleton = DeviceService._internal();
  factory DeviceService() => _singleton;
  DeviceService._internal() {
    initPlatformState();
  }
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  AndroidDeviceInfo? _androidInfo;
  IosDeviceInfo? _iosInfo;

  bool get isAndroid => Platform.isAndroid;
  bool get isIos => Platform.isIOS;
  String get localizationValue => 'ru';

  get deviceUID {
    const unknownDevice = 'unknown';

    if (isAndroid) {
      return _androidInfo?.id ?? unknownDevice;
    } else if (isIos) {
      return _iosInfo?.identifierForVendor ?? unknownDevice;
    }

    return unknownDevice;
  }

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        _androidInfo = await deviceInfoPlugin.androidInfo;
      } else if (Platform.isIOS) {
        _iosInfo = await deviceInfoPlugin.iosInfo;
      }
    } catch (e) {
      ExceptionHandlers().getExceptionString(e);
    }
  }
}
