import 'package:biluca_financas/components/base_page.dart';
import 'package:biluca_financas/components/mouse_back_button_listener.dart';
import 'package:biluca_financas/reports/components/month_selector.dart';
import 'package:flutter/material.dart';

class MonthlyReport extends StatefulWidget {
  const MonthlyReport({super.key});

  @override
  State<StatefulWidget> createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return MouseBackButtonListener(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Relatório mensal'),
            ),
            body: BasePage(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MonthSelector(
                  current: _selectedDate,
                  onDateChanged: (date) => setState(
                    () {
                      _selectedDate = date;
                    },
                  ),
                ),
              ],
            ))));
  }
}
