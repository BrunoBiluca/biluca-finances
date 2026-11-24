import 'package:biluca_financas/core/accountability_monthly_report/services/current_month_report.service.dart';
import 'package:flutter/material.dart';

class MonthlyReportServiceProvider extends InheritedWidget {
  final CurrentMonthReportService service;

  const MonthlyReportServiceProvider({
    super.key,
    required this.service,
    required super.child,
  });

  // Static method to access the service
  static CurrentMonthReportService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<MonthlyReportServiceProvider>();
    assert(provider != null, 'MonthlyReportServiceProvider não encontrado na árvore');
    return provider!.service;
  }

  @override
  bool updateShouldNotify(MonthlyReportServiceProvider oldWidget) {
    return service != oldWidget.service;
  }
}
