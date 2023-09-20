import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hr_events/mvvm/data/providers/providers.dart';
import 'package:hr_events/mvvm/screens/events/events_view.dart';

class BottomSheetEvents {
  void showForAndroid(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 185,
        child: ListView(
          key: const Key('actionSheet'),
          padding: EdgeInsets.zero,
          children: [
            _GenerateListTile('global.bottom_sheet.news_and_events'.tr(),
                keyListTile: 'news_and_events_list_tile',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            _GenerateListTile('global.bottom_sheet.news'.tr(), keyListTile: 'news_list_tile', type: 140),
            _GenerateListTile('global.bottom_sheet.events'.tr(), keyListTile: 'events_list_tile', type: 10),
            const Divider(
              thickness: 1,
              height: 2,
              indent: 0,
            ),
            _GenerateListTile(
              'global.cancel'.tr(),
              keyListTile: 'cancel_list_tile',
            ),
          ],
        ),
      ),
    );
  }

  void showForIOS(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        key: const Key('actionSheet'),
        actions: [
          _GenerateCupertinoActionSheetAction('global.bottom_sheet.news_and_events'.tr(),
              keyListTile: 'news_and_events_list_tile',
              isDefaultAction: true,
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          _GenerateCupertinoActionSheetAction('global.bottom_sheet.news'.tr(),
              keyListTile: 'news_list_tile',
              type: 140,
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          _GenerateCupertinoActionSheetAction('global.bottom_sheet.events'.tr(),
              keyListTile: 'events_list_tile',
              type: 10,
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ],
        cancelButton: _GenerateCupertinoActionSheetAction('global.cancel'.tr(),
            keyListTile: 'cancel_list_tile', isDestructiveAction: true),
      ),
    );
  }
}

class _GenerateCupertinoActionSheetAction extends ConsumerWidget {
  final String name;
  final bool isDefaultAction;
  final bool isDestructiveAction;
  final int? type;
  final TextStyle? style;
  final String keyListTile;

  const _GenerateCupertinoActionSheetAction(
    this.name, {
    this.type,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.style,
    required this.keyListTile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoActionSheetAction(
      key: Key(keyListTile),
      isDefaultAction: isDefaultAction,
      isDestructiveAction: isDestructiveAction,
      child: Text(name, style: style),
      onPressed: () {
        ref.read(eventsProvider.notifier).fetchSelectedList(ref: ref, type: type);
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const EventsView(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          (route) => false,
        );
      },
    );
  }
}

class _GenerateListTile extends ConsumerWidget {
  final String name;
  final TextStyle? style;
  final int? type;
  final String keyListTile;

  const _GenerateListTile(
    this.name, {
    required this.keyListTile,
    this.style,
    this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      key: Key(keyListTile),
      visualDensity: const VisualDensity(vertical: -3),
      title: Text(name, style: style),
      onTap: () {
        Navigator.of(context).pushNamedAndRemoveUntil(EventsView.routeName, (route) => false);
        ref.read(eventsProvider.notifier).fetchSelectedList(ref: ref, type: type);
      },
    );
  }
}
