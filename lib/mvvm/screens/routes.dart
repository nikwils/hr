import 'package:flutter/material.dart';

import 'package:hr_events/mvvm/screens/date_picker.dart';
import 'package:hr_events/mvvm/screens/event/event_view.dart';
import 'package:hr_events/mvvm/screens/events/events_view.dart';
import 'package:hr_events/mvvm/screens/favorite_events/favorite_events_view.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> routesMap = {
    EventsView.routeName: ((ctx) => const EventsView()),
    EventView.routeName: ((ctx) => const EventView()),
    FavoriteEventsView.routeName: ((ctx) => const FavoriteEventsView()),
    DatePicker.routeName: ((ctx) => const DatePicker()),
  };
}
