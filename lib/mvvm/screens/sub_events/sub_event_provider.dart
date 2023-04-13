import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr/mvvm/data/models/favorite_events/favorite_event_model.dart';
import 'package:hr/mvvm/data/models/favorite_events/favorite_lenta_model.dart';

import 'package:hr/services/api/api_controller_service.dart';
import 'package:hr/services/api/api_service.dart';
import 'package:hr/services/exception_handlers/exception_handlers.dart';

class SubEventProvider
    extends StateNotifier<AsyncValue<List<FavoriteEventModel>>> {
  SubEventProvider() : super(const AsyncValue.data([])) {
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
          .get(controller: ApiControllerService.favoriteLenta);

      if (response == null || response.statusCode != 200) throw Exception();

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        final data = FavoriteLentaModel.fromJson(json);

        _favoriteEvents = data.res.favoriteList;
        state = AsyncValue.data(_favoriteEvents);
      }
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }
  }

  Future refresh() async {
    try {
      if (_favoriteEvents.length != state.asData?.value.length) {
        await fetchFavoriteEvents();
      }
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }
  }
}
