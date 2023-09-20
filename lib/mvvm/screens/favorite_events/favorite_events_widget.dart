import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_events/mvvm/data/models/favorite_events/favorite_event_model.dart';
import 'package:hr_events/mvvm/data/providers/providers.dart';
import 'package:hr_events/mvvm/screens/event/event_view.dart';
import 'package:hr_events/services/device_service.dart';

class FavoriteEventsWidget extends ConsumerWidget {
  const FavoriteEventsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteEvents = ref.watch(favoriteEventProvider);
    final notifier = ref.watch(favoriteEventProvider.notifier);

    return favoriteEvents.when(
      data: (data) => RefreshIndicator(
        onRefresh: () {
          return notifier.refresh();
        },
        child: data.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.only(top: 20),
                itemCount: data.length,
                itemBuilder: (BuildContext context, int i) {
                  FavoriteEventModel event = data[i];
                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pushNamed(EventView.routeName,
                          arguments: {
                            'id': event.eventId,
                            'title': event.name
                          });
                    },
                    child: Card(
                      key: ValueKey('favorite_event_$i'),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                        height: 80,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                event.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  'favorite_events_view.favorite_events_empty'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
      ),
      error: (Object error, StackTrace stackTrace) {
        return RefreshIndicator(
          onRefresh: () => notifier.fetchFavoriteEvents(),
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
