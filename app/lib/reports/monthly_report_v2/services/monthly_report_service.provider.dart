import 'package:biluca_financas/reports/monthly_report_v2/services/current_month_report.service.dart';
import 'package:flutter/material.dart';

class MonthlyReportServiceProvider extends InheritedWidget {
  final CurrentMonthReportService service;

  const MonthlyReportServiceProvider({
    super.key,
    required this.service,
    required super.child,
  });

  // Método estático para acessar o serviço
  static CurrentMonthReportService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<MonthlyReportServiceProvider>();
    assert(provider != null, 'ServiceAProvider não encontrado na árvore');
    return provider!.service;
  }

  @override
  bool updateShouldNotify(MonthlyReportServiceProvider oldWidget) {
    return service != oldWidget.service;
  }
}
