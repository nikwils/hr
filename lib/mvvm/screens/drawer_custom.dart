import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:hr_events/mvvm/screens/events/events_view.dart';
import 'package:hr_events/mvvm/screens/favorite_events/favorite_events_view.dart';
import 'package:hr_events/services/theme/theme_manager.dart';

class DrawerCustom extends StatelessWidget {
  const DrawerCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ThemeManager.drawerColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 30, 8, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ListTile(
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  onTap: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(EventsView.routeName, (route) => false),
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    'global.drawer.titles.event_list'.tr(),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                ),
                ListTile(
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  onTap: () async {
                    Navigator.of(context).popAndPushNamed(FavoriteEventsView.routeName);
                  },
                  leading: const Icon(Icons.notifications),
                  title: Text('global.drawer.titles.my_favorite'.tr()),
                  trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
