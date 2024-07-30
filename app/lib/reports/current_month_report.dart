import 'package:biluca_financas/reports/current_month_card.dart';
import 'package:biluca_financas/sqlite/current_month_service.dart';
import 'package:biluca_financas/sqlite/db_provider.dart';
import 'package:flutter/material.dart';

class CurrentMonthReport extends StatefulWidget {
  const CurrentMonthReport({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentMonthReportState();
}

class _CurrentMonthReportState extends State<CurrentMonthReport> {
  late String _selectedMonth;
  late List<String> availableMonths = [];

  @override
  void initState() {
    super.initState();

    var now = DateTime.now();
    _selectedMonth = formatMonth(now.month, now.year);

    availableMonths = [];
    for (var year = 2022; year <= now.year; year++) {
      for (var month = 1; month <= 12; month++) {
        if (month > now.month && year == now.year) {
          break;
        }
        availableMonths.add(formatMonth(month, year));
      }
    }
  }

  String formatMonth(int month, int year) {
    return "${month < 10 ? '0' : ''}$month/$year";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DBProvider.i.database,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        return Column(
          children: [
            DropdownButton<String>(
              value: _selectedMonth,
              onChanged: (month) {
                setState(() {
                  _selectedMonth = month!;
                });
              },
              items: availableMonths.map((m) => DropdownMenuItem<String>(value: m, child: Text(m))).toList(),
            ),
            const SizedBox(height: 20),
            Text("Resumo do mês $_selectedMonth"),
            const SizedBox(height: 20),
            FutureBuilder(
              future: DBProvider.i.database,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }
                return CurrentMonthCard(
                  service: SQLiteAccontabilityCurrentMonthService(db: snapshot.data!, month: _selectedMonth),
                );
              },
            )
          ],
        );
      },
    );
  }
}
