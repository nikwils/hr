import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_events/mvvm/screens/event/event_widget.dart';
import 'package:hr_events/services/device_service.dart';
import 'package:hr_events/services/exception_handlers/exception_handlers.dart';
import 'package:hr_events/services/theme/theme_manager.dart';

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
    final eventModel = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    final String title = eventModel['title'] as String;

    return DeviceService().isAndroid
        ? _scaffoldAndroid(title: title, context: context, id: eventModel['id'])
        : _scaffoldIOS(title: title, context: context, id: eventModel['id']);
  }
}

Scaffold _scaffoldAndroid(
    {required String title, required context, required int id}) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        title,
        textAlign: TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chevron_left),
      ),
    ),
    body: EventWidget(id),
  );
}

CupertinoPageScaffold _scaffoldIOS(
    {required String title, required context, required id}) {
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      backgroundColor: ThemeManager.mainColor,
      middle: Text(
        title,
        textAlign: TextAlign.left,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    child: EventWidget(id),
  );
}
