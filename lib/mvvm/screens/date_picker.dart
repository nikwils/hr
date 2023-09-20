import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_events/mvvm/screens/events/events_view.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:hr_events/mvvm/data/providers/providers.dart';

class DatePicker extends ConsumerStatefulWidget {
  const DatePicker({super.key});
  static const routeName = '/date_picker';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends ConsumerState<DatePicker> {
  late List<DateTime> _eventsDates;

  @override
  void initState() {
    _eventsDates = _getEventsDates();
    super.initState();
  }

  List<DateTime> _getEventsDates() {
    final notifier = ref.read(eventsProvider.notifier);
    return notifier.dateListEvents;
  }

  @override
  Widget build(BuildContext context) {
    DateRangePickerController controller = DateRangePickerController();
    return SafeArea(
      child: Scaffold(
        body: SfDateRangePicker(
          confirmText: 'global.ok'.tr(),
          cancelText: 'global.cancel'.tr(),
          view: DateRangePickerView.month,
          selectionMode: DateRangePickerSelectionMode.range,
          enableMultiView: true,
          navigationMode: DateRangePickerNavigationMode.scroll,
          navigationDirection: DateRangePickerNavigationDirection.vertical,
          monthCellStyle: DateRangePickerMonthCellStyle(
            specialDatesDecoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(
                color: Colors.blue,
              ),
              shape: BoxShape.circle,
            ),
            specialDatesTextStyle: const TextStyle(color: Colors.white),
          ),
          monthViewSettings: DateRangePickerMonthViewSettings(
            firstDayOfWeek: 1,
            specialDates: _eventsDates,
            enableSwipeSelection: false,
          ),
          showActionButtons: true,
          controller: controller,
          onSubmit: (date) {
            Navigator.of(context).pushNamedAndRemoveUntil(EventsView.routeName, (route) => false);
            ref.read(titleProvider.notifier).state = "events_view.title.news_and_events".tr();

            ref.read(eventsProvider.notifier).controlControllerSearchRangeDate(controller.selectedRange);
          },
          onCancel: () {
            Navigator.of(context).pushNamedAndRemoveUntil(EventsView.routeName, (route) => false);
            ref.read(eventsProvider.notifier).cancelDatePicker(ref);
          },
        ),
      ),
    );
  }
}
