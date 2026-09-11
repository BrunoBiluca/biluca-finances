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
          Expanded(
            child: DropdownButton<String>(
              value: currentYear,
              style: Theme.of(context).textTheme.displayLarge,
              iconSize: 36,
              iconEnabledColor: color,
              dropdownColor: Colors.black,
              focusColor: Colors.black,
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
          )
        ],
      ),
    );
  }
}
