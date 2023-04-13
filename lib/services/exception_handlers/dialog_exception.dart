import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:hr_events/services/context_service.dart';
import 'package:hr_events/services/device_service.dart';

class DialogException {
  void showAlertDialog({
    required String title,
    required String content,
  }) {
    final BuildContext context = ContextService.navigatorKey.currentContext!;
    DeviceService().isAndroid
        ? showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('global.ok'.tr()),
                  ),
                ],
              );
            },
          )
        : showCupertinoDialog(
            context: context,
            builder: (contex) {
              return CupertinoAlertDialog(
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('global.ok'.tr()),
                  ),
                ],
              );
            },
          );
  }
}
