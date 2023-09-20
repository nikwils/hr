import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_events/mvvm/data/models/favorite_events/favorite_event_model.dart';
import 'package:hr_events/mvvm/data/models/favorite_events/favorite_lenta_model.dart';
import 'package:hr_events/services/api/api_controller_service.dart';
import 'package:hr_events/services/api/api_service.dart';
import 'package:hr_events/services/exception_handlers/exception_handlers.dart';

class FavoriteEventProvider
    extends StateNotifier<AsyncValue<List<FavoriteEventModel>>> {
  FavoriteEventProvider() : super(const AsyncValue.data([])) {
    fetchFavoriteEvents();
  }

  List<FavoriteEventModel> _favoriteEvents = [];

  List<FavoriteEventModel> get getFavoriteEvents => _favoriteEvents;

  set setFavoriteEvents(List<FavoriteEventModel> favoriteEvents) {
    _favoriteEvents = favoriteEvents;
  }

  Future<void> fetchFavoriteEvents() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService()
          .get(controller: ApiControllerService.favoriteEvents);

      if (response == null || response.statusCode != 200) throw Exception();

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        final data = FavoriteLentaModel.fromJson(json);

        _favoriteEvents = data.res.favoriteList;
        state = AsyncValue.data(_favoriteEvents);
      }
    } catch (e) {
      ExceptionHandlers().getExceptionString(e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    await fetchFavoriteEvents();
  }
}
