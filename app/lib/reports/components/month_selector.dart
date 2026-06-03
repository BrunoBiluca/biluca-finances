import 'package:biluca_financas/common/extensions/string_extensions.dart';
import 'package:biluca_financas/reports/accountability_month_stats.dart';
import 'package:biluca_financas/reports/accountability_stats_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatefulWidget {
  final Function(DateTime) onDateChanged;
  final DateTime current;
  const MonthSelector({super.key, required this.onDateChanged, required this.current});

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  final DateFormat dateformat = DateFormat("yyyy/MM", "pt_BR");

  late String _selectedMonth;
  late List<AccountabilityMonthStats> availableMonths = [];

  @override
  void initState() {
    _selectedMonth = formatDate(widget.current.year, widget.current.month);
    fillMonths();
    super.initState();
  }

  void fillMonths() async {
    var service = GetIt.I<AccountabilityStatsService>();
    var result = await service.getAllMonthsWithAccountability(fillBlanks: true);

    if (mounted) {
      setState(() {
        availableMonths = result;
      });
    }
  }

  String formatDate(int year, int month) => dateformat.format(DateTime(year, month)).capitalize();

  DateTime parseDate() => dateformat.parse(_selectedMonth.toLowerCase());

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
          DropdownButton<String>(
            value: _selectedMonth,
            style: Theme.of(context).textTheme.displayLarge,
            iconSize: 36,
            iconEnabledColor: color,
            dropdownColor: Colors.black,
            focusColor: Colors.black,
            menuMaxHeight: 400,
            underline: Container(),
            onChanged: (month) {
              setState(() {
                _selectedMonth = month!;
                widget.onDateChanged(parseDate());
              });
            },
            items: availableMonths
                .map(
                  (m) => DropdownMenuItem<String>(
                    value: m.month,
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
