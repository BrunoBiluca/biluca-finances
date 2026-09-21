import 'package:biluca_financas/core/accountability_stats/models/accountability_year_stats.dart';
import 'package:flutter/material.dart';

class YearSelector extends StatelessWidget {
  final String currentYear;
  final List<AccountabilityYearStats> years;
  final Function(String) onDateChanged;

  const YearSelector({
    super.key,
    required this.years,
    required this.onDateChanged,
    required this.currentYear,
  });

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
        value: currentYear,
        style: textStyle,
        iconSize: size,
        iconEnabledColor: color,
        dropdownColor: Theme.of(context).cardColor,
        menuMaxHeight: 400,
        underline: Container(),
        isExpanded: true,
        onChanged: (year) => onDateChanged(year!),
        items: years
            .map(
              (y) => DropdownMenuItem<String>(
                value: y.year,
                child: Text(y.year + (y.entriesCount == 0 ? " (empty)" : "")),
              ),
            )
            .toList(),
      ),
    );
  }
}
