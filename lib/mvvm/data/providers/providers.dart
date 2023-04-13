import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr/mvvm/data/models/detail/detail_event_model.dart';
import 'package:hr/mvvm/data/models/favorite_events/favorite_event_model.dart';
import 'package:hr/mvvm/data/models/lenta/lenta_event_model.dart';
import 'package:hr/mvvm/screens/events/events_provider.dart';
import 'package:hr/mvvm/screens/event/event_provider.dart';
import 'package:hr/mvvm/screens/sub_events/sub_event_provider.dart';
//Providers
//Provider
//StateProvider
//StateNotifier & StateNotiierProvider
//FutureProvider (лучше реализовывать в отдельном классе ProviderRef)
//StreamProvider
//AsyncProvider
//AsyncNotifierProvider

final eventsProvider =
    StateNotifierProvider<EventsProvider, AsyncValue<List<LentaEventModel>>>(
        (ref) {
  return EventsProvider();
});

final eventProvider = StateNotifierProvider.family<EventProvider,
    AsyncValue<DetailEventModel>, int>((ref, id) {
  return EventProvider(id);
});

final subEventProvider = StateNotifierProvider.autoDispose<SubEventProvider,
    AsyncValue<List<FavoriteEventModel>>>((ref) {
  return SubEventProvider();
});

final controllerProvider = StateProvider<String>((ref) {
  return "";
});
