import 'dart:async';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/identifications_view_section.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/month_selector.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/summary_last_months_section.dart';
import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/common/ui/reports/report_header.dart';
import 'package:biluca_financas/common/ui/reports/report_section.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/common/ui/base_dialog.dart';
import 'package:biluca_financas/core/accountability_stats/models/accountability_month_stats.dart';
import 'package:biluca_financas/core/accountability_stats/services/accountability_stats_service.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/current_month_report.service.dart';
import 'package:biluca_financas/core/preferences/preferences_service.dart';
import 'package:biluca_financas/core/preferences/report_period_selection.dart';
import 'package:biluca_financas/app/accountability_monthly_report/monthly_report_service.provider.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/summary_values_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class MonthlyReport extends StatefulWidget {
  const MonthlyReport({super.key});

  @override
  State<StatefulWidget> createState() => _MonthlyReportState();
}

class _MonthlyReportState extends State<MonthlyReport> {
  List<AccountabilityMonthStats> availableMonths = [];
  AccountabilityMonthStats? _selectedMonth;
  CurrentMonthReportService? _service;
  StreamSubscription? _subscription;
  var statsService = GetIt.I<AccountabilityStatsService>();
  var preferences = GetIt.I<PreferencesService>();

  @override
  void initState() {
    super.initState();
    fillMonths();
  }

  void fillMonths() async {
    var result = await statsService.getAllMonthsWithAccountability(fillBlanks: true);
    setState(() => availableMonths = result);
    final initial = ReportPeriodSelection.resolveMonth(
      availableMonths: result,
      savedMonth: preferences.selectedMonth,
    );
    if (initial != null) updateDateSelected(initial);
  }

  void selectMonth(AccountabilityMonthStats month) {
    preferences.setSelectedMonth(month.month);
    updateDateSelected(month);
  }

  void updateDateSelected(AccountabilityMonthStats month) {
    _subscription?.cancel();
    _service?.dispose();

    setState(() {
      _selectedMonth = month;
      var parsedMonth = DateFormat("yyyy/MM").parse(_selectedMonth!.month);
      _service = GetIt.I<CurrentMonthReportService>(param1: parsedMonth);
      _subscription = _service!.onChange.listen((_) {
        updateDateSelected(_selectedMonth!);
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service?.dispose();
    super.dispose();
  }

  void displayReportData() async {
    var changedAccountability = false;

    Size size = MediaQuery.of(context).size;

    double width = size.width;
    double height = size.height;

    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => BaseDialog(
          title: "Registros de ${_selectedMonth!.month}",
          content: SizedBox(
            width: width - 300,
            height: height - 300,
            child: BlocProvider(
              create: (_) => AccountabilityBloc(repo: _service!.current)..add(FetchAccountabilityEntries()),
              child: BlocBuilder<AccountabilityBloc, AccountabilityState>(
                builder: (context, state) {
                  if (state.entries.isEmpty) {
                    return const Center(child: Text('Nenhuma entrada registrada'));
                  }

                  return AccountabilityTable(
                    entries: state.entries,
                    onUpdate: (entry) {
                      context.read<AccountabilityBloc>().add(UpdateAccountabilityEntry(entry));
                      changedAccountability = true;
                    },
                    onRemove: (entry) {
                      context.read<AccountabilityBloc>().add(DeleteAccountabilityEntry(entry));
                      changedAccountability = true;
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      if (changedAccountability) {
        updateDateSelected(_selectedMonth!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (availableMonths.isEmpty || _selectedMonth == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return MonthlyReportServiceProvider(
      key: ValueKey(_selectedMonth!.month),
      service: _service!,
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ReportHeader(
            icon: Icons.dashboard,
            iconColor: Colors.purpleAccent,
            title: "Relatório mensal",
            actions: [
              ElevatedButton(
                onPressed: () => displayReportData(),
                child: const Row(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 20),
                    Text('Dados do relatório'),
                  ],
                ),
              ),
            ],
            periodSelector: MonthSelector(
              availableMonths: availableMonths,
              current: _selectedMonth!,
              onDateChanged: selectMonth,
            ),
          ),
          _selectedMonth!.entriesCount == 0
              ? SizedBox(
                  height: 400,
                  child: const Center(
                    child: Text("Nenhum registro encontrado"),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 60,
                  children: [
                    SummaryValuesSection(),
                    SummaryLastMonthsSection(),
                    ReportSection(
                      title: "Receitas por Identificação",
                      icon: Icons.savings_outlined,
                      child: FutureHandler(
                        dependency: _service,
                        load: () => _service!.incomesByIdentification(),
                        builder: (context, data) => IdentificationsViewSection(
                          data: data,
                          onDataChanged: () {
                            updateDateSelected(_selectedMonth!);
                          },
                        ),
                      ),
                    ),
                    ReportSection(
                      title: "Despesas por Identificação",
                      icon: Icons.money_off_outlined,
                      child: FutureHandler(
                        dependency: _service,
                        load: () => _service!.expensesByIdentification(),
                        builder: (context, data) => IdentificationsViewSection(
                          data: data,
                          onDataChanged: () {
                            updateDateSelected(_selectedMonth!);
                          },
                        ),
                      ),
                    ),
                    // ExpensesPerIndentification(service: _service!),
                  ],
                ),
          const SizedBox(height: 100)
        ],
      ),
    );
  }
}
