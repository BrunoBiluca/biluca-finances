import 'package:biluca_financas/components/base_page.dart';
import 'package:biluca_financas/components/mouse_back_button_listener.dart';
import 'package:biluca_financas/reports/components/month_selector.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/current_month_report.service.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/monthly_report_service.provider.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/summary_values_section/summary_values_section.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MonthlyReportV2 extends StatefulWidget {
  const MonthlyReportV2({super.key});

  @override
  State<StatefulWidget> createState() => _MonthlyReportV2State();
}

class _MonthlyReportV2State extends State<MonthlyReportV2> {
  late DateTime _selectedDate;
  late CurrentMonthReportService _service;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    updateDateSelected(_selectedDate);
  }

  void updateDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _service = GetIt.I<CurrentMonthReportService>(param1: _selectedDate);
    });
  }

  void displayReportData() {}

  @override
  Widget build(BuildContext context) {
    return MouseBackButtonListener(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Relatório mensal'),
            ),
            body: MonthlyReportServiceProvider(
                service: _service,
                child: BasePage(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      MonthSelector(
                        current: _selectedDate,
                        onDateChanged: updateDateSelected,
                      ),
                      OutlinedButton(
                        onPressed: () => displayReportData(),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline),
                            SizedBox(width: 20),
                            Text('Dados do relatório'),
                          ],
                        ),
                      )
                    ]),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SummaryValuesSection(),
                      ),
                    )
                  ],
                )))));
  }
}
