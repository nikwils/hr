import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr/mvvm/data/providers/providers.dart';
import 'package:hr/mvvm/screens/bottom_sheet_events.dart';
import 'package:hr/mvvm/screens/drawer_events.dart';
import 'package:hr/mvvm/screens/events/events_widget.dart';
import 'package:hr/services/device_service.dart';
import 'package:hr/services/theme/theme_manager.dart';

class EventsView extends ConsumerStatefulWidget {
  const EventsView({super.key});

  static const routeName = '/events';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ViewState();
}

class ViewState extends ConsumerState<EventsView> {
  @override
  Widget build(BuildContext context) {
    final titleName = ref.watch(eventsProvider.notifier).getTitleName;

    return DeviceService().isAndroid
        ? scaffoldAndroid(titleName, context)
        : scaffoldIOS(titleName, context);
  }
}

final bottomSheetEvents = BottomSheetEvents();

Scaffold scaffoldAndroid(String titleName, BuildContext context) {
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
          key: const Key("settingsButton"),
        ),
      ],
    ),
    drawer: const DrawerEvents(),
    body: const EventsWidget(),
  );
}

Scaffold scaffoldIOS(String titleName, BuildContext context) {
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
          child: const Icon(
            CupertinoIcons.slider_horizontal_3,
          ),
        ),
      ],
    ),
    drawer: const DrawerEvents(),
    body: const EventsWidget(),
  );
}




/*Scaffold scaffoldAndroid(titleName, BuildContext context) {
  final viewModel = context.watch<EventsViewModel>();
  String? value = viewModel.getValueDropdownMenu;
  return Scaffold(
    appBar: AppBar(
        centerTitle: true,
        title: DropdownButton<String>(
          value: value,
          focusColor: Colors.grey,
          style: TextTheme().titleMedium,
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem(
              child: Text('КОнтакты'),
              value: 'Контакты',
            ),
            DropdownMenuItem(
              child: Text('two'),
              value: 'two',
            ),
          ],
          onChanged: (String? value) {
            viewModel.changePage(value);
          },
        )),
    drawer: const DrawerEvents(),
    body: const EventsWidget(),
  );
}*/
