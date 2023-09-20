import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_events/mvvm/data/models/detail/detail_event_model.dart';
import 'package:hr_events/mvvm/data/models/detail/detail_model.dart';
import 'package:hr_events/mvvm/data/providers/providers.dart';
import 'package:hr_events/services/api/api_controller_service.dart';
import 'package:hr_events/services/api/api_service.dart';
import 'package:hr_events/services/event_type/event_type_controller_service.dart';
import 'package:hr_events/services/exception_handlers/exception_handlers.dart';
import 'package:hr_events/services/imgs/imgs_controller_service.dart';
import 'package:hr_events/services/notifications/local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class EventProvider extends StateNotifier<AsyncValue<DetailEventModel>?> {
  final int _eventModelId;
  Map<int, Map<String, String>> listEmailPhoneUrlData = {};

  EventProvider(this._eventModelId) : super(null) {
    fetchEventContent();
  }

  bool _isEvent = false;
  get isEventContent => _isEvent;

  Future<void> subscribe({required DetailEventModel eventContent, required bool value}) async {
    try {
      final response = await ApiService().post(
        controller: ApiControllerService.favoriteEvents,
        body: {
          'eventId': _eventModelId.toString(),
          'type': value ? 'POST' : 'DELETE',
        },
      );
      if (response != null && response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['Success'] == 1) {
          LocalNotifications().callLocalNotification(value, eventContent);
        } else {
          LocalNotifications().callLocalNotification(null, eventContent);
        }
      }
    } catch (e) {
      ExceptionHandlers().getExceptionString(e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> fetchEventContent() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService().post(
        controller: ApiControllerService.event,
        body: {
          'id': _eventModelId.toString(),
        },
      );
      if (response == null || response.statusCode != 200) throw Exception();

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = DetailModel.fromJson(json);
        setEventContent(data.res.eventContent);
      }
    } catch (e) {
      ExceptionHandlers().getExceptionString(e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void setEventContent(DetailEventModel eventContent) {
    try {
      eventContent.picture ??= '';
      eventContent.id ??= _eventModelId;
      eventContent.dateStart ??= '';
      eventContent.dateEnd ??= '';
      eventContent.timeStart ??= '';
      eventContent.timeEnd ??= '';
      eventContent.location ??= '';
      eventContent.address ??= '';

      if (eventContent.dateStart != '') {
        final date = DateTime.parse(eventContent.dateStart!);
        eventContent.dateStart = DateFormat.yMMMMd("global.localization".tr()).format(date).toString();
      }
      if (eventContent.timeStart != '') {
        eventContent.timeStart = eventContent.timeStart!.substring(0, eventContent.timeStart!.length - 3);
      }
      if (eventContent.timeEnd != '') {
        eventContent.timeEnd = eventContent.timeEnd!.substring(0, eventContent.timeEnd!.length - 3);
      }
    } catch (e) {
      ExceptionHandlers().getExceptionString(e);
      state = AsyncValue.error(e, StackTrace.current);
    }
    checkEvent(eventContent);
  }

  void checkEvent(DetailEventModel eventContent) {
    if (eventContent.type == EventTypeControllerService.events.type()) {
      _isEvent = true;
    } else {
      _isEvent = false;
    }
    state = AsyncValue.data(eventContent);
  }

  void switcher({
    required bool value,
    required DetailEventModel eventContent,
    required WidgetRef ref,
  }) {
    if (state == null) return;

    state?.asData?.value.inFavorite = value;
    ref.watch(eventProvider(_eventModelId).notifier).subscribe(eventContent: eventContent, value: value);
  }

  Image chooseImg(String? picture) {
    final defaultImg = Image.asset(
      fit: BoxFit.cover,
      ImgsControllerService.defaultImg.url(),
    );
    if (picture == '' || picture == null) {
      return defaultImg;
    }
    return Image.network(
      picture.toString(),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return defaultImg;
      },
    );
  }

  Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  bool timeCheck(DetailEventModel data) {
    return data.dateStart != '' &&
        data.timeStart != '' &&
        data.timeStart != '00:00' &&
        data.timeEnd != '' &&
        data.timeEnd != '00:00' &&
        data.location != '' &&
        data.address != '';
  }

  double factHeightContainer(int? contactsLength) {
    double heightContainer = 55;

    contactsLength ??= 0;
    double factHeight = heightContainer * contactsLength;
    if (factHeight > heightContainer) {
      heightContainer = factHeight.toDouble();
    }
    return heightContainer;
  }

  Map<int, Map<String, String>> listEmailPhoneUrl(
    List<Map<String, dynamic>>? eventContacts,
  ) {
    Map<int, Map<String, String>> list = {};

    int index = 0;

    if (eventContacts != null && eventContacts.isNotEmpty) {
      for (var i = 0; i < eventContacts.length; i++) {
        String title = '';

        switch (eventContacts[i]['Type']) {
          case '1':
            title = 'url';
            break;
          case '2':
            title = 'email';
            break;

          case '3':
            title = 'phone';
            break;
        }

        list[index] = {
          'Name': 'event_view.modal_bottom_sheet.title_$title'.tr(),
          'Data': eventContacts[i]['Data']
        };
        index++;
      }
    }

    listEmailPhoneUrlData = list;
    return list;
  }

  void showModalForAndroid(BuildContext context, DetailEventModel selectedEvent) {
    double heightContainer = factHeightContainer(selectedEvent.eventContacts?.length);

    Map<int, Map<String, String>>? listTiles = listEmailPhoneUrl(selectedEvent.eventContacts);

    final bool enabled = listTiles.isNotEmpty ? true : false;
    final int factItemCount = listTiles.length > 1 ? listTiles.length : 1;

    showModalBottomSheet(
      elevation: 1,
      context: context,
      builder: (context) => SizedBox(
        height: heightContainer,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: factItemCount,
          itemBuilder: (BuildContext context, int index) {
            String nameTitle = 'event_view.modal_bottom_sheet.title_default_value'.tr();
            String nameTrailing = '';
            if (listTiles.containsKey(index) &&
                listTiles[index]!['Name'] != null &&
                listTiles[index]!['Data'] != null) {
              nameTitle = listTiles[index]!['Name'].toString();
              nameTrailing = listTiles[index]!['Data'].toString();
            }

            return ListTile(
              key: const Key('copyData'),
              enabled: enabled,
              title: Text(
                nameTitle,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                _copyData(selectedEvent, index);
                _showDialogForAndroid(context);
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      nameTrailing,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void showModalForIOS(BuildContext context, DetailEventModel selectedEvent) {
    double heightContainer = factHeightContainer(selectedEvent.eventContacts?.length);

    Map<int, Map<String, String>>? listTiles = listEmailPhoneUrl(selectedEvent.eventContacts);

    final bool enabled = listTiles.isNotEmpty ? true : false;
    final int factItemCount = listTiles.length > 1 ? listTiles.length : 1;
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
        height: heightContainer,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemCount: factItemCount,
          itemBuilder: (BuildContext context, int index) {
            String nameTitle = 'event_view.modal_bottom_sheet.title_default_value'.tr();
            String nameTrailing = '';
            if (listTiles.containsKey(index) &&
                listTiles[index]!['Name'] != null &&
                listTiles[index]!['Data'] != null) {
              nameTitle = listTiles[index]!['Name'].toString();
              nameTrailing = listTiles[index]!['Data'].toString();
            }
            final Color listTileColor = enabled ? Colors.black : Colors.grey;
            return CupertinoListTile(
              key: const Key('copyData'),
              title: Text(
                nameTitle,
                style: TextStyle(
                  color: listTileColor,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              onTap: () async {
                if (enabled) {
                  _copyData(selectedEvent, index);
                  _showDialogForIOS(context);
                }
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Text(
                        nameTrailing,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: listTileColor,
                    size: 18,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _copyData(DetailEventModel selectedEvent, int index) async {
    if (listEmailPhoneUrlData[index] == null) return;
    final text = listEmailPhoneUrlData[index]!['Data'].toString();
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
            buttonPadding: EdgeInsets.zero,
            key: const Key('alertDialog'),
            backgroundColor: Colors.white,
            title: Text(
              'event_view.modal_bottom_sheet.copied_to_clipboard'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  child: Text('global.ok'.tr(), style: const TextStyle(fontSize: 16)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
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
            key: const Key('alertDialog'),
            content: Text(
              'event_view.modal_bottom_sheet.copied_to_clipboard'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'global.ok'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
      },
    );
  }
}
