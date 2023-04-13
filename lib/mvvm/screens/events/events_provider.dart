import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr/mvvm/data/models/detail/detail_event_model.dart';
import 'package:hr/mvvm/data/models/detail/detail_model.dart';
import 'package:hr/mvvm/data/models/lenta/lenta_event_model.dart';
import 'package:hr/mvvm/data/models/lenta/lenta_model.dart';
import 'package:hr/services/api/api_controller_service.dart';
import 'package:hr/services/api/api_service.dart';
import 'package:hr/services/event_type/event_type_controller_service.dart';
import 'package:hr/services/exception_handlers/exception_handlers.dart';
import 'package:hr/services/theme/theme_manager.dart';

class EventsProvider extends StateNotifier<AsyncValue<List<LentaEventModel>>> {
  EventsProvider() : super(const AsyncValue.data([])) {
    fetchEvents();
  }

  List<LentaEventModel> _events = [];
  LentaEventModel _event = LentaEventModel(id: 0, type: 0, name: '');
  String _titleName = 'Riverpod';
  final TextEditingController controllerSearch = TextEditingController();
  final DateTime today = DateTime.now();
  List<LentaEventModel>? _selectedEvents;
  String? _valueDropdownMenu = 'Контакты';

  get getEvents => _selectedEvents ?? [..._events];
  get getTitleName => _titleName;
  LentaEventModel get getEvent => _event;
  String get getValueDropdownMenu => _valueDropdownMenu ?? '';

  Widget chooseImg(picture) {
    return picture != ""
        ? Image.network(
            (picture).toString(),
            height: 100,
            width: 500.0,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          )
        : Container(
            width: double.infinity,
            height: 170,
            color: Colors.grey[300],
          );
  }

  Future<void> fetchEvents() async {
    try {
      state = const AsyncValue.loading();
      final response =
          await ApiService().post(controller: ApiControllerService.lenta);

      if (response == null || response.statusCode != 200) throw Exception();

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = LentaModel.fromJson(json);

        setEvents(data.res.lenta);
      }
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }
  }

  LentaEventModel findEventById({required int id}) {
    List<LentaEventModel> events = getEvents;
    _event = events.firstWhere((event) => event.id == id);
    return _event;
  }

  void setEvents(List<LentaEventModel> events) {
    try {
      for (LentaEventModel e in events) {
        if (e.dateStart != '' && e.dateStart != null) {
          final date = DateTime.parse(e.dateStart!);
          e.dateStart = DateFormat.yMMMMd('ru').format(date).toString();
        } else {
          e.dateStart = 'Скоро объявим';
        }
        e.announce ??= "Классное мероприятие";
      }
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }
    state = AsyncValue.data(events);
    _events = events;
  }

  void fetchSelectedList({int? type}) {
    state = AsyncValue.data(_events);
    if (type != null) {
      final value = _events.where((e) => e.type == type).toList();
      state = AsyncValue.data(value);
      changeTitle(type: type);
      return;
    }
    changeTitle();
  }

  void searchEvent({required String value, required String property}) {
    final suggestions = _events.where((e) {
      if (property == "name") {
        String eventDateStart = '';
        if (e.dateStart != null) {
          eventDateStart = e.dateStart?.toLowerCase() ?? eventDateStart;
        }
        final eventName = e.name.toLowerCase();
        final input = value.toLowerCase();
        return eventName.contains(input) || eventDateStart.contains(input);
      } else {
        if (e.dateStart != null) {
          final eventDateStart = e.dateStart!.toLowerCase();
          final input = value.toLowerCase();
          return eventDateStart.contains(input);
        }
        return false;
      }
    }).toList();
    state = AsyncValue.data(suggestions);
  }

  void changeTitle({int? type}) {
    if (type == EventTypeControllerService.eventType.type()) {
      _titleName = "events_view.title.events".tr();
    } else if (type == EventTypeControllerService.newsType.type()) {
      _titleName = "events_view.title.news".tr();
    } else {
      _titleName = "events_view.title.news_and_events".tr();
    }
  }

  void clearTextField() {
    controllerSearch.clear();
    state = AsyncValue.data(_events);
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 360)),
      initialDate: today,
      lastDate: today,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ThemeManager.calendarColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final date = DateFormat.yMMMMd('ru').format(picked).toString();

      controllerSearch.text =
          date.replaceRange(date.indexOf('2') - 1, date.length, "");

      searchEvent(value: controllerSearch.text, property: 'date');
    }
  }

  void changePage(String? value) {
    _valueDropdownMenu = value;
  }

  Future<void> subscribe({required int id, required bool value}) async {
    try {
      await ApiService().post(
        controller: ApiControllerService.favoriteLenta,
        body: {
          'eventId': id.toString(),
          'type': value ? 'POST' : 'DELETE',
        },
      );
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }
  }

  Future<DetailEventModel> fetchEventContent({required int id}) async {
    late DetailEventModel eventContent;
    try {
      final response = await ApiService().post(
        controller: ApiControllerService.event,
        body: {
          'id': id.toString(),
        },
      );

      if (response == null || response.statusCode != 200) throw Exception();

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = DetailModel.fromJson(json);
        eventContent = data.res.eventContent;
        return eventContent;
      }
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }
    return eventContent;
  }
}
