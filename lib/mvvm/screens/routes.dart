import 'package:flutter/material.dart';

import 'package:hr_events/mvvm/screens/event/event_view.dart';
import 'package:hr_events/mvvm/screens/events/events_view.dart';
import 'package:hr_events/mvvm/screens/sub_events/sub_events_view.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routesMap = {
    EventsView.routeName: ((ctx) => const EventsView()),
    EventView.routeName: ((ctx) => const EventView()),
    SubEventsView.routeName: ((ctx) => const SubEventsView()),
  };
}
