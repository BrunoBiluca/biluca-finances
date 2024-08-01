import 'package:biluca_financas/reports/amount_by_identification_chart.dart';
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
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
            Expanded(
              child: FutureBuilder(
                future: DBProvider.i.database,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }
                  var service = SQLiteAccontabilityCurrentMonthService(db: snapshot.data!, month: _selectedMonth);
                  return Column(
                    children: [
                      CurrentMonthCard(service: service),
                      const SizedBox(height: 20),
                      Expanded(
                          child: FutureBuilder(
                              future: service.getTotalByIdentification(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState != ConnectionState.done) {
                                  return const CircularProgressIndicator();
                                }

                                if (snapshot.data == null || snapshot.data!.isEmpty) {
                                  return const Text("Nenhum item encontrado");
                                }

                                return SizedBox(
                                  width: 400,
                                  height: 600,
                                  child: AmountByIdentificationChart(accountabilityByIdentification: snapshot.data!),
                                );
                              }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
