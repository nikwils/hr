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
                contentPadding: const EdgeInsets.only(
                    right: 24.0, top: 20.0, left: 24.0, bottom: 0),
                actionsPadding: EdgeInsets.zero,
                actionsAlignment: MainAxisAlignment.center,
                title: Text(title),
                content: Text(content),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
                      Navigator.of(context).pop();
                    },
                    child: Text('global.ok'.tr()),
                  ),
                ],
              );
            },
          );
  }
}
