import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr/mvvm/data/providers/providers.dart';
import 'package:hr/mvvm/screens/event/event_widget.dart';
import 'package:hr/services/device_service.dart';
import 'package:hr/services/exception_handlers/exception_handlers.dart';
import 'package:hr/services/theme/theme_manager.dart';

class EventView extends ConsumerStatefulWidget {
  const EventView({super.key});
  static const routeName = '/event';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventViewState();
}

class _EventViewState extends ConsumerState<EventView> {
  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context) == null) {
      throw ExceptionHandlers().getExceptionString();
    }

    final eventModelId = ModalRoute.of(context)?.settings.arguments as int;
    final event =
        ref.watch(eventsProvider.notifier).findEventById(id: eventModelId);
    final title = event.name;
    return DeviceService().isAndroid
        ? _scaffoldAndroid(title: title, context: context)
        : _scaffoldIOS(title: title, context: context);
  }
}

Scaffold _scaffoldAndroid({required String title, required context}) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chevron_left),
      ),
    ),
    body: const SafeArea(
      child: EventWidget(),
    ),
  );
}

CupertinoPageScaffold _scaffoldIOS({required String title, required context}) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      backgroundColor: ThemeManager.mainColor,
      middle: Text(title, textAlign: TextAlign.center),
    ),
    child: const EventWidget(),
  );
}
