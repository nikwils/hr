import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr/mvvm/data/models/detail/detail_event_model.dart';
import 'package:hr/mvvm/data/providers/providers.dart';
import 'package:hr/services/device_service.dart';
import 'package:hr/services/theme/theme_manager.dart';

class EventWidget extends ConsumerStatefulWidget {
  const EventWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends ConsumerState<EventWidget> {
  @override
  Widget build(BuildContext context) {
    final eventModelId = ModalRoute.of(context)?.settings.arguments as int;
    final selectedEvent = ref.watch(eventProvider(eventModelId));
    final notifier = ref.watch(eventProvider(eventModelId).notifier);

    return selectedEvent.when(
      data: (data) => SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 220,
                padding: const EdgeInsets.only(top: 8),
                child: notifier.chooseImg(data.picture),
              ),
              const Divider(
                thickness: 1,
              ),
              _TimeADateOfEvent(data),
              notifier.isEventContent
                  ? WidgetForEvent(eventModelId)
                  : const SizedBox(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 15),
                child: _DescColumn(eventModelId),
              )
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => Text(error.toString()),
      loading: () => Center(
        child: DeviceService().isAndroid
            ? const CircularProgressIndicator()
            : const CupertinoActivityIndicator(),
      ),
    );
  }
}

class WidgetForEvent extends ConsumerWidget {
  final int eventModelId;

  const WidgetForEvent(this.eventModelId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _ListTileCreate('notifications', eventModelId),
        const _Divider(),
        _ListTileCreate('email', eventModelId),
        const _Divider(),
      ],
    );
  }
}

class _TimeADateOfEvent extends ConsumerWidget {
  final DetailEventModel selectedEvent;

  const _TimeADateOfEvent(this.selectedEvent);

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 80, minWidth: 150),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Icon(
                    Icons.watch_later_outlined,
                    color: ThemeManager.iconDefaultColor,
                  ),
                ),
                Text(selectedEvent.dateStart!),
                Text(selectedEvent.timeStart!)
              ],
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 80, minWidth: 150),
            child: Column(children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Icon(
                  Icons.location_on_sharp,
                  color: ThemeManager.iconDefaultColor,
                ),
              ),
              Text(
                selectedEvent.location!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                selectedEvent.address!,
                textAlign: TextAlign.center,
              )
            ]),
          )
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      indent: 70,
      thickness: 1,
      height: 1,
    );
  }
}

class _ListTileCreate extends ConsumerStatefulWidget {
  final String _typeListTile;
  final int _eventModelId;
  const _ListTileCreate(this._typeListTile, this._eventModelId);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ListTileCreateState();
}

class _ListTileCreateState extends ConsumerState<_ListTileCreate> {
  @override
  Widget build(BuildContext context) {
    final selectedEvent =
        ref.watch(eventProvider(widget._eventModelId)).asData!.value;
    final notifier = ref.watch(eventProvider(widget._eventModelId).notifier);

    if (widget._typeListTile == 'notifications') {
      return DeviceService().isAndroid
          ? SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: Text('event_view.list_title.follow'.tr()),
              value: selectedEvent.inFavorite,
              onChanged: (bool value) {
                notifier.switcher(
                    value: value, eventContent: selectedEvent, ref: ref);
                setState(() {});
              },
            )
          : CupertinoListTile(
              leading: const Icon(
                CupertinoIcons.bell_fill,
                color: ThemeManager.iconDefaultColor,
              ),
              title: Text('event_view.list_title.follow'.tr()),
              trailing: CupertinoSwitch(
                value: selectedEvent.inFavorite,
                onChanged: (value) {
                  notifier.switcher(
                      value: value, eventContent: selectedEvent, ref: ref);
                  setState(() {});
                },
              ),
            );
    } else {
      return DeviceService().isAndroid
          ? ListTile(
              leading: const Icon(
                Icons.email,
                color: ThemeManager.iconDefaultColor,
              ),
              title: Text(
                'event_view.list_title.email_for_feedback'.tr(),
              ),
              onTap: () => notifier.showModalForAndroid(context, selectedEvent),
              trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            )
          : CupertinoListTile(
              leading: const Icon(
                CupertinoIcons.mail_solid,
                color: ThemeManager.iconDefaultColor,
              ),
              title: Text(
                'event_view.list_title.email_for_feedback'.tr(),
              ),
              trailing: const Icon(
                CupertinoIcons.chevron_right,
                color: ThemeManager.iconDefaultColor,
              ),
              onTap: () => notifier.showModalForAndroid(context, selectedEvent),
            );
    }
  }
}

class _DescColumn extends ConsumerWidget {
  final int _eventModelId;
  const _DescColumn(this._eventModelId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEvent = ref.watch(eventProvider(_eventModelId)).asData!.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(selectedEvent.title, style: const TextStyle(fontSize: 22)),
        Html(
          data: selectedEvent.content,
          shrinkWrap: true,
        ),
      ],
    );
  }
}
