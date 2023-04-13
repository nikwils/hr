import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:hr_events/services/exception_handlers/exception_handlers.dart';

class DeviceService {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  AndroidDeviceInfo? _androidInfo;
  IosDeviceInfo? _iosInfo;

  bool get isAndroid => Platform.isAndroid;
  bool get isIos => Platform.isIOS;
  get deviceUID {
    const unknownDevice = 'browser';

    if (isAndroid) {
      return _androidInfo?.id ?? unknownDevice;
    } else if (isIos) {
      return _iosInfo?.identifierForVendor ?? unknownDevice;
    }

    return unknownDevice;
  }

  DeviceService() {
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    //Map<String, dynamic> deviceData = {};

    try {
      if (Platform.isAndroid) {
        _androidInfo = await deviceInfoPlugin.androidInfo;
        //deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        _iosInfo = await deviceInfoPlugin.iosInfo;
        //deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }
  }

  //сохранять локально id, чтобы не смог затираться кеш - самый безопасный

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
          ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
      'serialNumber': build.serialNumber,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}
