import 'package:biluca_financas/core/accountability_stats/models/accountability_month_stats.dart';
import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  final Function(AccountabilityMonthStats) onDateChanged;
  final AccountabilityMonthStats current;
  final List<AccountabilityMonthStats> availableMonths;

  const MonthSelector({super.key, required this.onDateChanged, required this.current, required this.availableMonths});

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyLarge!;
    var size = textStyle.fontSize!;
    Color color = textStyle.color!;

    return Card(
      child: DropdownButton<String>(
        icon: Icon(
          Icons.calendar_month,
          color: Theme.of(context).colorScheme.primary,
          size: size,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        value: current.month,
        style: textStyle,
        iconSize: size,
        iconEnabledColor: color,
        dropdownColor: Theme.of(context).cardColor,
        menuMaxHeight: 400,
        underline: Container(),
        isExpanded: true,
        onChanged: (month) => onDateChanged(availableMonths.firstWhere((m) => m.month == month)),
        items: availableMonths
            .map(
              (m) => DropdownMenuItem<String>(
                value: m.month,
                child: Text(
                  m.month + (m.entriesCount == 0 ? " (empty)" : ""),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
