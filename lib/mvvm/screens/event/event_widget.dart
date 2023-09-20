import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_events/mvvm/data/models/detail/detail_event_model.dart';
import 'package:hr_events/mvvm/data/providers/providers.dart';
import 'package:hr_events/mvvm/screens/event/event_provider.dart';
import 'package:hr_events/services/device_service.dart';
import 'package:hr_events/services/theme/theme_manager.dart';

class EventWidget extends ConsumerStatefulWidget {
  final int id;
  const EventWidget(this.id, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends ConsumerState<EventWidget> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<DetailEventModel>? selectedEvent =
        ref.watch(eventProvider(widget.id));

    if (selectedEvent == null) return const SizedBox();
    final EventProvider notifier = ref.watch(eventProvider(widget.id).notifier);

    return selectedEvent.when(
      data: (data) {
        final bool haveDateATime = notifier.timeCheck(data);

        return SingleChildScrollView(
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
                notifier.isEventContent && haveDateATime
                    ? _TimeADateOfEvent(data)
                    : const SizedBox(),
                notifier.isEventContent
                    ? WidgetForEvent(widget.id)
                    : const SizedBox(),
                Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 15),
                  child: _ContentColumn(widget.id),
                )
              ],
            ),
          ),
        );
      },
      error: (Object error, StackTrace stackTrace) {
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(eventProvider(widget.id).notifier).fetchEventContent(),
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
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.watch_later_outlined,
                  color: ThemeManager.iconDefaultColor,
                ),
                InfoOnCard(selectedEvent.dateStart!),
                InfoOnCard(
                  selectedEvent.timeStart!,
                  addValue: selectedEvent.timeEnd!,
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.location_on_sharp,
                  color: ThemeManager.iconDefaultColor,
                ),
                InfoOnCard(
                  selectedEvent.address!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InfoOnCard(selectedEvent.location!),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InfoOnCard extends ConsumerWidget {
  final String data;
  final TextStyle? style;
  final String? addValue;
  const InfoOnCard(this.data, {this.style, this.addValue, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data == '' || data == '0:00') return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: addValue != '' && addValue != null
          ? Text(
              '$data - $addValue',
              style: style,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              data,
              style: style,
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
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
    DetailEventModel? selectedEvent =
        ref.watch(eventProvider(widget._eventModelId))?.asData?.value;
    final notifier = ref.watch(eventProvider(widget._eventModelId).notifier);

    if (selectedEvent == null) return const SizedBox();

    if (widget._typeListTile == 'notifications') {
      return DeviceService().isAndroid
          ? SwitchListTile(
              key: const Key("switcherNotification"),
              secondary: const Icon(Icons.notifications),
              title: Text('event_view.list_title.follow_events'.tr()),
              value: selectedEvent.inFavorite,
              onChanged: (bool value) {
                notifier.switcher(
                    value: value, eventContent: selectedEvent, ref: ref);
                setState(() {});
              },
            )
          : CupertinoListTile(
              key: const Key("switcherNotification"),
              leading: const Icon(
                CupertinoIcons.bell_fill,
                color: ThemeManager.iconDefaultColor,
              ),
              title: Text('event_view.list_title.follow_events'.tr()),
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
              key: const Key('contacts'),
              leading: const Icon(
                Icons.email,
                color: ThemeManager.iconDefaultColor,
              ),
              title: Text(
                'event_view.list_title.contacts_for_feedback'.tr(),
              ),
              onTap: () => notifier.showModalForAndroid(context, selectedEvent),
              trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            )
          : CupertinoListTile(
              key: const Key('contacts'),
              leading: const Icon(
                CupertinoIcons.mail_solid,
                color: ThemeManager.iconDefaultColor,
              ),
              title: Text(
                'event_view.list_title.contacts_for_feedback'.tr(),
              ),
              trailing: const Icon(
                CupertinoIcons.chevron_right,
                color: ThemeManager.iconDefaultColor,
              ),
              onTap: () => notifier.showModalForIOS(context, selectedEvent),
            );
    }
  }
}

class _ContentColumn extends ConsumerWidget {
  final int _eventModelId;
  const _ContentColumn(this._eventModelId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(eventProvider(_eventModelId).notifier);
    DetailEventModel? selectedEvent =
        ref.watch(eventProvider(_eventModelId))?.asData?.value;

    if (selectedEvent == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(selectedEvent.title, style: const TextStyle(fontSize: 22)),
        Html(
          data: selectedEvent.content,
          shrinkWrap: true,
          onLinkTap: (url, attributes, element) async {
            if (url == null || url == '') return;
            notifier.launchURL(url);
          },
          extensions: const [
            TableHtmlExtension(),
          ],
          style: {
            "th": Style(
              padding: HtmlPaddings.symmetric(horizontal: 8),
              border: Border.all(color: Colors.black),
            ),
            "td": Style(
              padding: HtmlPaddings.only(left: 5),
              border: Border.all(color: Colors.black),
            ),
          },
        ),
      ],
    );
  }
}
