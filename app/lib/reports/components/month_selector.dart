import 'package:biluca_financas/reports/accountability_month_stats.dart';
import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  final Function(AccountabilityMonthStats) onDateChanged;
  final AccountabilityMonthStats current;
  final List<AccountabilityMonthStats> availableMonths;

  const MonthSelector({
    super.key,
    required this.onDateChanged,
    required this.current,
    required this.availableMonths,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).textTheme.displayLarge!.color!;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 4, color: color),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 10),
          DropdownButton<AccountabilityMonthStats>(
            value: current,
            style: Theme.of(context).textTheme.displayLarge,
            iconSize: 36,
            iconEnabledColor: color,
            dropdownColor: Colors.black,
            focusColor: Colors.black,
            menuMaxHeight: 400,
            underline: Container(),
            onChanged: (month) => onDateChanged(month!),
            items: availableMonths
                .map(
                  (m) => DropdownMenuItem<AccountabilityMonthStats>(
                    value: m,
                    child: Text(m.month + (m.entriesCount == 0 ? " (empty)" : "")),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
