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
  String _selectedMonth = "07/2024";

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
              items: [
                "07/2024",
                "08/2024",
                "09/2024",
              ].map((month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
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
