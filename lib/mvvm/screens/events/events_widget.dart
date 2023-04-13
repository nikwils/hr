import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr/mvvm/data/models/lenta/lenta_event_model.dart';
import 'package:hr/mvvm/data/providers/providers.dart';

import 'package:hr/mvvm/screens/event/event_view.dart';
import 'package:hr/services/device_service.dart';
import 'package:hr/services/theme/theme_manager.dart';

class EventsWidget extends ConsumerStatefulWidget {
  const EventsWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => WidgetState();
}

class WidgetState extends ConsumerState<EventsWidget> {
  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);

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
            child: DeviceService().isAndroid
                ? const _TextFormSearchAndroid()
                : const _TextFormSearchIOS(),
          ),
          Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.only(top: 20),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int i) {
              LentaEventModel event = data[i];
              return GestureDetector(
                onTap: () async {
                  print('id event ${event.id}');
                  Navigator.of(context)
                      .pushNamed(EventView.routeName, arguments: event.id);
                },
                child: Card(
                  key: Key('card_key_$i'),
                  child: Column(
                    children: [
                      event.picture != ""
                          ? SizedBox(
                              child: Image.network(
                                height: 100,
                                width: 500.0,
                                (event.picture).toString(),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 170,
                              color: Colors.grey[300],
                            ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.all(
                          10,
                        ),
                        height: 160,
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(event.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(event.dateStart!),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              event.announce!,
                              maxLines: 4,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ))
        ]);
      },
      loading: () => Center(
        child: DeviceService().isAndroid
            ? const CircularProgressIndicator()
            : const CupertinoActivityIndicator(),
      ),
      error: (Object error, StackTrace stackTrace) {
        return Center(
          child: Text(error.toString()),
        );
      },
    );
  }
}

class _TextFormSearchAndroid extends ConsumerStatefulWidget {
  const _TextFormSearchAndroid();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TextFormSearchAndroidState();
}

class _TextFormSearchAndroidState
    extends ConsumerState<_TextFormSearchAndroid> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(eventsProvider.notifier);
    final controllerText = ref.watch(controllerProvider);

    return TextFormField(
      controller: notifier.controllerSearch,
      onChanged: (value) {
        notifier.searchEvent(value: value, property: 'name');
        ref.read(controllerProvider.notifier).state = value;
      },
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: ('events_view.input_placeholder'.tr()),
        prefixIcon: IconButton(
          alignment: Alignment.topCenter,
          icon:
              Icon(Icons.calendar_month, color: Theme.of(context).primaryColor),
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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __TextFormSearchIOSState();
}

class __TextFormSearchIOSState extends ConsumerState<_TextFormSearchIOS> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(eventsProvider.notifier);

    return CupertinoTextField(
      controller: notifier.controllerSearch,
      onChanged: (value) {
        notifier.searchEvent(value: value, property: 'name');
      },
      prefix: CupertinoButton(
        alignment: Alignment.topCenter,
        onPressed: () {
          notifier.selectDate(context);
        },
        child:
            const Icon(CupertinoIcons.calendar, color: ThemeManager.mainColor),
      ),
      suffix: notifier.controllerSearch.text.isEmpty
          ? null
          : CupertinoButton(
              onPressed: () {
                notifier.clearTextField();
              },
              child: const Icon(CupertinoIcons.clear,
                  color: ThemeManager.iconDefaultColor)),
      placeholder: ('events_view.input_placeholder'.tr()),
    );
  }
}
