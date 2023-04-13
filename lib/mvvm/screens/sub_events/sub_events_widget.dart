import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_events/mvvm/data/models/favorite_events/favorite_event_model.dart';

import 'package:hr_events/mvvm/data/providers/providers.dart';
import 'package:hr_events/mvvm/screens/event/event_view.dart';
import 'package:hr_events/services/device_service.dart';

class SubEventsWidget extends ConsumerWidget {
  const SubEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteEvents = ref.watch(subEventProvider);
    final notifier = ref.watch(subEventProvider.notifier);

    return RefreshIndicator(
        onRefresh: () {
          return notifier.refresh();
        },
        child: favoriteEvents.when(
          data: (data) => ListView.builder(
            padding: const EdgeInsets.only(top: 20),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int i) {
              FavoriteEventModel event = data[i];
              return GestureDetector(
                onTap: () async {
                  Navigator.of(context)
                      .pushNamed(EventView.routeName, arguments: event.eventId);
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            event.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          error: (Object error, StackTrace stackTrace) {
            return Center(
              child: Text(error.toString()),
            );
          },
          loading: () => Center(
            child: DeviceService().isAndroid
                ? const CircularProgressIndicator()
                : const CupertinoActivityIndicator(),
          ),
        ));
  }
}
