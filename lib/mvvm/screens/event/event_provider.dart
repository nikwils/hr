import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr/mvvm/data/models/detail/detail_event_model.dart';
import 'package:hr/mvvm/data/models/detail/detail_model.dart';
import 'package:hr/mvvm/data/providers/providers.dart';
import 'package:hr/services/api/api_controller_service.dart';
import 'package:hr/services/api/api_service.dart';
import 'package:hr/services/event_type/event_type_controller_service.dart';
import 'package:hr/services/exception_handlers/exception_handlers.dart';
import 'package:hr/services/imgs/imgs_controller_service.dart';
import 'package:hr/services/notifications/local_notifications.dart';

class EventProvider extends StateNotifier<AsyncValue<DetailEventModel>> {
  EventProvider(eventModelId)
      : super(AsyncValue.data(
            DetailEventModel(content: '', title: '', inFavorite: false))) {
    fetchEventContent(id: eventModelId);
  }

  bool _isEvent = false;
  DetailEventModel _selectedEventContent =
      DetailEventModel(content: '', title: '', inFavorite: false);

  get isEventContent => _isEvent;
  get getEventContent => _selectedEventContent;

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

  Future<void> fetchEventContent({required int id}) async {
    state = const AsyncValue.loading();
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
        setEventContent(data.res.eventContent);
      }
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }
  }

  void setEventContent(DetailEventModel eventContent) {
    try {
      if (eventContent.dateStart != '' && eventContent.dateStart != null) {
        final date = DateTime.parse(eventContent.dateStart!);
        eventContent.dateStart =
            DateFormat.yMMMMd('ru').format(date).toString();
      } else {
        eventContent.dateStart = '1 января 1970';
      }
      if (eventContent.email == null || eventContent.email!.isEmpty) {
        eventContent.email = [
          {"Name": "Почта", "Data": "Почта не указана"}
        ];
      }
      eventContent.id = 0;
      eventContent.timeStart ??= 'Скоро';
      eventContent.type ??= 10;
      eventContent.location ??= 'Аэропорт ДМЕ';
      eventContent.address ??= 'Домодедово';
    } on ExceptionHandlers catch (e) {
      e.getExceptionString(e);
    }
    checkEvent(eventContent);
  }

  void checkEvent(DetailEventModel eventContent) {
    if (eventContent.type == EventTypeControllerService.eventType.type()) {
      _isEvent = true;
    } else {
      _isEvent = false;
    }
    _selectedEventContent = eventContent;
    state = AsyncValue.data(eventContent);
  }

  void switcher(
      {required bool value,
      required DetailEventModel eventContent,
      required WidgetRef ref}) {
    state.asData?.value.inFavorite = value;
    LocalNotifications().callLocalNotification(value, eventContent);
    ref
        .watch(eventsProvider.notifier)
        .subscribe(id: eventContent.id!, value: value);
  }

  Image chooseImg(picture) {
    return picture.toString() != ''
        ? Image.network(
            picture.toString(),
            fit: BoxFit.cover,
          )
        : Image.asset(ImgsControllerService.defaultImg.url());
  }

  void showModalForAndroid(
      BuildContext context, DetailEventModel selectedEvent) {
    showModalBottomSheet(
      elevation: 1,
      context: context,
      builder: (context) => SizedBox(
        height: 60,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: Text("event_view.modal_bottom_sheet.title".tr()),
              onTap: () async {
                _copyEmail(selectedEvent);
                _showDialogForAndroid(context);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedEvent.email![0]['Data'].toString()),
                  const Icon(Icons.keyboard_arrow_right)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showModalForIOS(BuildContext context, DetailEventModel selectedEvent) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        height: 45,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            CupertinoListTile(
              title: Text("event_view.modal_bottom_sheet.title".tr()),
              onTap: () async {
                _copyEmail(selectedEvent);
                _showDialogForIOS(context);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedEvent.email == null
                        ? 'почты нет'
                        : selectedEvent.email![0].toString(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    size: 18,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyEmail(DetailEventModel selectedEvent) async {
    final text = selectedEvent.email![0]['Data'].toString();
    await Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );
  }

  Future _showDialogForAndroid(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            content: Text(
              'event_view.modal_bottom_sheet.copied_to_clipboard'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          );
        });
  }

  Future _showDialogForIOS(context) {
    return showCupertinoDialog(
      context: context,
      builder: (_) {
        return Theme(
          data: ThemeData.dark(),
          child: CupertinoAlertDialog(
            content: Text(
              'event_view.modal_bottom_sheet.copied_to_clipboard'.tr(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18),
            ),
          ),
        );
      },
    );
  }
}
