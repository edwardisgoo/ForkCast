import 'package:flutter/material.dart';
import 'package:flutter_app/models/openingHours.dart';

class TimePeriodText extends StatelessWidget {
  final TimePeriod period;

  const TimePeriodText({super.key, required this.period});

  static const List<String> weekdayNames = [
    '星期天', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六',
  ];

  String formatHourMin(dynamic hm) {
    final hour = hm.hour.toString().padLeft(2, '0');
    final minute = hm.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final dayStr = (period.day >= 0 && period.day <= 6)
        ? weekdayNames[period.day]
        : '未知星期';
    final startStr = formatHourMin(period.start);
    final endStr = formatHourMin(period.end);

    return Text(
      '$dayStr $startStr - $endStr',
      style: const TextStyle(fontSize: 16),
    );
  }
}

class TimePeriodListView extends StatelessWidget {
  final List<TimePeriod> periods;

  const TimePeriodListView({super.key, required this.periods});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: periods
          .map((period) => TimePeriodText(period: period))
          .toList(),
    );
  }
}