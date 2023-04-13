import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_events/mvvm/screens/sub_events/sub_events_widget.dart';
import 'package:hr_events/services/device_service.dart';
import 'package:hr_events/services/theme/theme_manager.dart';

class SubEventsView extends ConsumerWidget {
  const SubEventsView({super.key});
  static const routeName = '/sub_events';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DeviceService().isAndroid
        ? _scaffoldAndroid(context)
        : _scaffoldIOS(context);
  }
}

Scaffold _scaffoldAndroid(context) {
  return Scaffold(
    appBar:
        AppBar(title: Text('sub_events_view.title.event_subscriptions'.tr())),
    body: const SubEventsWidget(),
  );
}

CupertinoPageScaffold _scaffoldIOS(context) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      backgroundColor: ThemeManager.mainColor,
      middle: Text('sub_events_view.title.event_subscriptions'.tr(),
          textAlign: TextAlign.center),
    ),
    child: const SubEventsWidget(),
  );
}
