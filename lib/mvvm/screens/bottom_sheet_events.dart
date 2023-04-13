import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_events/mvvm/data/providers/providers.dart';

import 'package:hr_events/mvvm/screens/events/events_view.dart';

class BottomSheetEvents {
  showForAndroid(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 185,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _GenerateListTile("global.bottom_sheet.news_and_events".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            _GenerateListTile("global.bottom_sheet.news".tr(), type: 140),
            _GenerateListTile("global.bottom_sheet.events".tr(), type: 10),
            const Divider(
              thickness: 1,
              height: 2,
              indent: 0,
            ),
            _GenerateListTile("global.bottom_sheet.cancel".tr()),
          ],
        ),
      ),
    );
  }

  showForIOS(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          _GenerateCupertinoActionSheetAction(
              "global.bottom_sheet.news_and_events".tr(),
              isDefaultAction: true,
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          _GenerateCupertinoActionSheetAction("global.bottom_sheet.news".tr(),
              type: 140,
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          _GenerateCupertinoActionSheetAction("global.bottom_sheet.events".tr(),
              type: 10,
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ],
        cancelButton: _GenerateCupertinoActionSheetAction(
            "global.bottom_sheet.cancel".tr(),
            isDestructiveAction: true),
      ),
    );
  }
}

//
class _GenerateCupertinoActionSheetAction extends ConsumerWidget {
  final String name;
  final bool isDefaultAction;
  final bool isDestructiveAction;
  final int? type;
  final TextStyle? style;

  const _GenerateCupertinoActionSheetAction(
    this.name, {
    this.type,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoActionSheetAction(
      isDefaultAction: isDefaultAction,
      isDestructiveAction: isDestructiveAction,
      child: Text(
        name,
        style: style,
      ),
      onPressed: () {
        ref.read(eventsProvider.notifier).fetchSelectedList(type: type);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const EventsView()));
      },
    );
  }
}

class _GenerateListTile extends ConsumerWidget {
  final String name;
  final TextStyle? style;
  final int? type;

  const _GenerateListTile(this.name, {this.style, this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -3),
      title: Text(name, style: style),
      onTap: () {
        ref.read(eventsProvider.notifier).fetchSelectedList(type: type);

        Navigator.of(context).pushNamed(EventsView.routeName);
      },
    );
  }
}
