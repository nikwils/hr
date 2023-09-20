import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_events/mvvm/data/models/detail/detail_event_model.dart';
import 'package:hr_events/mvvm/data/models/favorite_events/favorite_event_model.dart';
import 'package:hr_events/mvvm/data/models/lenta/lenta_event_model.dart';
import 'package:hr_events/mvvm/screens/events/events_provider.dart';
import 'package:hr_events/mvvm/screens/event/event_provider.dart';
import 'package:hr_events/mvvm/screens/favorite_events/favorite_event_provider.dart';

final eventsProvider = StateNotifierProvider<EventsProvider, AsyncValue<List<LentaEventModel>>>((ref) {
  return EventsProvider();
});

final eventProvider =
    StateNotifierProvider.autoDispose.family<EventProvider, AsyncValue<DetailEventModel>?, int>((ref, id) {
  return EventProvider(id);
});

final favoriteEventProvider =
    StateNotifierProvider.autoDispose<FavoriteEventProvider, AsyncValue<List<FavoriteEventModel>>>((ref) {
  return FavoriteEventProvider();
});

final controllerProvider = StateProvider<String>((ref) {
  return "";
});
final titleProvider = StateProvider<String>((ref) {
  return "events_view.title.news_and_events".tr();
});
