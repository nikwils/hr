import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_events/mvvm/data/providers/providers.dart';
import 'package:hr_events/mvvm/screens/bottom_sheet_events.dart';
import 'package:hr_events/mvvm/screens/drawer_custom.dart';
import 'package:hr_events/mvvm/screens/events/events_widget.dart';
import 'package:hr_events/services/device_service.dart';
import 'package:hr_events/services/notifications/notifications_firebase_service.dart';
import 'package:hr_events/services/theme/theme_manager.dart';

class EventsView extends ConsumerStatefulWidget {
  const EventsView({super.key});

  static const routeName = '/events';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventsViewState();
}

class _EventsViewState extends ConsumerState<EventsView> {
  @override
  void initState() {
    super.initState();
    FirebaseMessagingService().setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    final titleName = ref.watch(titleProvider.notifier).state;

    return DeviceService().isAndroid
        ? scaffoldAndroid(titleName, context, ref)
        : scaffoldIOS(titleName, context, ref);
  }
}

final bottomSheetEvents = BottomSheetEvents();

Scaffold scaffoldAndroid(String titleName, BuildContext context, WidgetRef ref) {
  return Scaffold(
    appBar: AppBar(
      title: Text(titleName),
      actions: [
        IconButton(
          padding: const EdgeInsets.only(right: 30),
          onPressed: () {
            bottomSheetEvents.showForAndroid(context);
          },
          icon: const Icon(
            Icons.display_settings,
          ),
          key: const ValueKey('groupButton'),
        ),
      ],
    ),
    drawer: const DrawerCustom(),
    body: const EventsWidget(),
  );
}

Scaffold scaffoldIOS(String titleName, BuildContext context, WidgetRef ref) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: ThemeManager.mainColor,
      title: Text(titleName),
      actions: [
        CupertinoButton(
          padding: const EdgeInsets.only(right: 30),
          onPressed: () {
            bottomSheetEvents.showForIOS(context);
          },
          key: const ValueKey('groupButton'),
          child: const Icon(
            CupertinoIcons.slider_horizontal_3,
          ),
        ),
      ],
    ),
    drawer: const DrawerCustom(),
    body: const EventsWidget(),
  );
}
