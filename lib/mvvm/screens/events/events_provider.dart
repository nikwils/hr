import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:hr_events/mvvm/data/models/lenta/lenta_event_model.dart';
import 'package:hr_events/mvvm/data/models/lenta/lenta_model.dart';
import 'package:hr_events/mvvm/data/providers/providers.dart';
import 'package:hr_events/mvvm/screens/date_picker.dart';
import 'package:hr_events/services/api/api_controller_service.dart';
import 'package:hr_events/services/api/api_service.dart';
import 'package:hr_events/services/event_type/event_type_controller_service.dart';
import 'package:hr_events/services/exception_handlers/exception_handlers.dart';

class EventsProvider extends StateNotifier<AsyncValue<List<LentaEventModel>>> {
  EventsProvider() : super(const AsyncValue.data([])) {
    fetchEvents();
  }

  final TextEditingController controllerSearch = TextEditingController();
  final List<DateTime> _dateList = [];
  final List<DateTime> _dateListEvents = [];

  List<LentaEventModel> _events = [];
  List<LentaEventModel> _selectedEvents = [];
  int? _typeEvent;

  List<DateTime> get dateListEvents => _dateListEvents;

  Widget chooseImg(String? picture, BuildContext context) {
    final actualSizeDevice = MediaQuery.of(context).size;
    final heightImg = actualSizeDevice.height / 6;

    final defaultPicture = Container(
      width: double.infinity,
      height: heightImg,
      color: Colors.grey[300],
    );

    if (picture == "" || picture == null) {
      return defaultPicture;
    }
    return SizedBox(
      child: Image.network(
        (picture).toString(),
        height: heightImg,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) {
          return defaultPicture;
        },
      ),
    );
  }

  Future<void> fetchEvents() async {
    try {
      state = const AsyncValue.loading();
      final response = await ApiService().post(controller: ApiControllerService.events);

      if (response == null) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = LentaModel.fromJson(json);

        setEvents(data.res.lenta);
      }
    } catch (e) {
      ExceptionHandlers().getExceptionString(e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void setEvents(List<LentaEventModel> events) {
    events.sort((a, b) {
      return b.dateStart!.compareTo(a.dateStart!);
    });

    for (LentaEventModel e in events) {
      if (e.dateStart != null && e.dateStart != '') {
        final date = DateTime.parse(e.dateStart!);
        if (e.type == EventTypeControllerService.events.type()) {
          _dateListEvents.add(date);
        }
        _dateList.add(date);
        e.dateStart = DateFormat.yMMMMd("global.localization".tr()).format(date).toString();
      } else {
        e.dateStart = '';
      }
      e.announce ??= 'events_view.default_data.announce'.tr();
    }
    _events = events;
    _selectedEvents = events;
    fetchSelectedList(type: _typeEvent);
  }

  void fetchSelectedList({WidgetRef? ref, int? type}) {
    controllerSearch.clear();
    _typeEvent = type;
    if (type != null) {
      final eventsByType = _events.where((e) => e.type == type).toList();
      if (type == EventTypeControllerService.events.type()) {
        ref?.read(titleProvider.notifier).state = "events_view.title.events".tr();
      } else if (type == EventTypeControllerService.news.type()) {
        ref?.read(titleProvider.notifier).state = "events_view.title.news".tr();
      }
      _selectedEvents = eventsByType;
      state = AsyncValue.data(eventsByType);
    } else {
      ref?.read(titleProvider.notifier).state = "events_view.title.news_and_events".tr();
      state = AsyncValue.data(_events);
    }
  }

  void searchEvent({required String value, required String property}) {
    if (state.value == null) return;

    List<LentaEventModel>? foundEvents;
    if (property == 'name') {
      foundEvents = _selectedEvents.where((event) {
        final eventName = event.name.toLowerCase();
        final input = value.toLowerCase();
        String eventDateStart = '';

        if (event.dateStart != null || event.dateStart != '') {
          eventDateStart = event.dateStart!.toLowerCase();
          return eventName.contains(input) || eventDateStart.contains(input);
        } else {
          return eventName.contains(input);
        }
      }).toList();
    } else {
      _selectedEvents = _events;
      foundEvents = _events.where((event) {
        return searchByDate(event, value, property);
      }).toList();
    }
    state = AsyncValue.data(foundEvents);
  }

  bool searchByDate(LentaEventModel event, String value, String property) {
    if (event.dateStart == null || event.dateStart == '') return false;

    final DateTime eventDateStart = DateFormat.yMMMMd("global.localization".tr()).parse(event.dateStart!);

    if (property == 'singleDate') {
      final initialDateRange = DateTime.parse(value.split(' ').first);

      if (eventDateStart == initialDateRange) {
        return true;
      }
    } else if (property == 'rangeDate') {
      final DateTime initialDateRange =
          DateTime.parse(value.split(' ').first).subtract(const Duration(days: 1));
      final DateTime finalDateRange = DateTime.parse(value.split(' ')[2]).add(const Duration(days: 1));

      if (eventDateStart.isAfter(initialDateRange) && eventDateStart.isBefore(finalDateRange)) {
        return true;
      }
    }
    return false;
  }

  void clearTextField() {
    controllerSearch.clear();
    state = AsyncValue.data(_selectedEvents);
  }

  Future<void> selectDate(BuildContext context) async {
    Navigator.of(context).pushNamed(DatePicker.routeName);
  }

  void controlControllerSearchRangeDate(PickerDateRange? date) {
    if (date == null || date.startDate == null) return;

    final DateTime startDate = date.startDate!;

    String dateFormatting(DateTime date) {
      String result = DateFormat.yMMMMd("global.localization".tr()).format(date);
      return result;
    }

    if (date.endDate == null) {
      searchEvent(value: '$startDate', property: 'singleDate');
      controllerSearch.text = dateFormatting(startDate);
    } else {
      final endDateFull = date.endDate!;
      final endDate = DateUtils.dateOnly(endDateFull);
      searchEvent(value: '$startDate $endDate', property: 'rangeDate');
      controllerSearch.text = '${dateFormatting(startDate)} - ${dateFormatting(endDate)}';
    }
  }

  void cancelDatePicker(WidgetRef ref) {
    ref.read(titleProvider.notifier).state = "events_view.title.news_and_events".tr();
    state = AsyncValue.data(_events);
  }
}
