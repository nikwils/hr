import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_events/mvvm/data/models/lenta/lenta_event_model.dart';
import 'package:hr_events/mvvm/data/providers/providers.dart';
import 'package:hr_events/mvvm/screens/event/event_view.dart';
import 'package:hr_events/services/device_service.dart';
import 'package:hr_events/services/theme/theme_manager.dart';

class EventsWidget extends ConsumerStatefulWidget {
  const EventsWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventsWidgetState();
}

class _EventsWidgetState extends ConsumerState<EventsWidget> {
  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    final notifier = ref.watch(eventsProvider.notifier);

    return events.when(
      data: (data) {
        return Column(mainAxisSize: MainAxisSize.max, children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 5, 5, 5),
            width: double.infinity,
            child: DeviceService().isAndroid ? const _TextFormSearchAndroid() : const _TextFormSearchIOS(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(eventsProvider.notifier).fetchEvents(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 20),
                itemCount: data.length,
                itemBuilder: (BuildContext context, int i) {
                  LentaEventModel event = data[i];
                  return GestureDetector(
                    onTap: () async {
                      if (kDebugMode) {
                        print('id event ${event.id}');
                      }
                      Navigator.of(context)
                          .pushNamed(EventView.routeName, arguments: {'id': event.id, 'title': event.name});
                    },
                    child: Card(
                      key: ValueKey('card_key_$i'),
                      child: Column(
                        children: [
                          notifier.chooseImg(event.picture, context),
                          const Divider(),
                          Container(
                            padding: const EdgeInsets.all(
                              16,
                            ),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      event.dateStart!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 12.0),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Text(
                                        event.announce!,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ]);
      },
      error: (Object error, StackTrace stackTrace) {
        return RefreshIndicator(
          onRefresh: () => ref.read(eventsProvider.notifier).fetchEvents(),
          child: Stack(
            children: <Widget>[
              ListView(),
              Center(
                child: Text('global.errors.refresh_page'.tr()),
              )
            ],
          ),
        );
      },
      loading: () => Center(
        child: DeviceService().isAndroid
            ? const CircularProgressIndicator()
            : const CupertinoActivityIndicator(),
      ),
    );
  }
}

class _TextFormSearchAndroid extends ConsumerStatefulWidget {
  const _TextFormSearchAndroid();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TextFormSearchAndroidState();
}

class _TextFormSearchAndroidState extends ConsumerState<_TextFormSearchAndroid> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(eventsProvider.notifier);
    final controllerText = ref.watch(controllerProvider);

    const borderStyle = OutlineInputBorder(
        borderSide: BorderSide(
      color: Color.fromARGB(255, 235, 235, 235),
    ));

    return TextFormField(
      controller: notifier.controllerSearch,
      onChanged: (value) {
        notifier.searchEvent(value: value, property: 'name');
        ref.read(controllerProvider.notifier).state = value;
      },
      decoration: InputDecoration(
        enabledBorder: borderStyle,
        focusedBorder: borderStyle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        hintStyle: const TextStyle(color: ThemeManager.iconDefaultColor),
        hintText: ('events_view.input_placeholder'.tr()),
        prefixIcon: IconButton(
          alignment: Alignment.topCenter,
          icon: Icon(Icons.calendar_month, color: Theme.of(context).primaryColor),
          onPressed: () {
            notifier.selectDate(context);
          },
        ),
        suffixIcon: controllerText.isEmpty
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: ThemeManager.iconDefaultColor,
                ),
                onPressed: () {
                  notifier.clearTextField();
                },
              ),
      ),
    );
  }
}

class _TextFormSearchIOS extends ConsumerStatefulWidget {
  const _TextFormSearchIOS();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TextFormSearchIOSState();
}

class _TextFormSearchIOSState extends ConsumerState<_TextFormSearchIOS> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(eventsProvider.notifier);
    final controllerText = ref.watch(controllerProvider);

    return CupertinoTextField(
      cursorColor: ThemeManager.mainColor,
      controller: notifier.controllerSearch,
      onChanged: (value) {
        notifier.searchEvent(value: value, property: 'name');
        ref.read(controllerProvider.notifier).state = value;
      },
      prefix: CupertinoButton(
        alignment: Alignment.topCenter,
        onPressed: () {
          notifier.selectDate(context);
        },
        child: const Icon(CupertinoIcons.calendar, color: ThemeManager.mainColor),
      ),
      suffix: controllerText.isEmpty
          ? null
          : CupertinoButton(
              onPressed: () {
                notifier.clearTextField();
              },
              child: const Icon(CupertinoIcons.clear, color: ThemeManager.iconDefaultColor),
            ),
      placeholder: ('events_view.input_placeholder'.tr()),
    );
  }
}
