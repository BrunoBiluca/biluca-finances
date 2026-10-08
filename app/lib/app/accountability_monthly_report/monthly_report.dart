import 'dart:async';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/identifications_view_section.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/month_selector.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/summary_last_months_section.dart';
import 'package:biluca_financas/common/ui/reports/future_handler.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/common/ui/base_dialog.dart';
import 'package:biluca_financas/core/accountability_stats/models/accountability_month_stats.dart';
import 'package:biluca_financas/core/accountability_stats/services/accountability_stats_service.dart';
import 'package:biluca_financas/core/accountability_monthly_report/services/current_month_report.service.dart';
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

  @override
  void initState() {
    super.initState();
    fillMonths();
  }

  void fillMonths() async {
    var result = await statsService.getAllMonthsWithAccountability(fillBlanks: true);
    setState(() => availableMonths = result);
    updateDateSelected(result.last);
  }

  void updateDateSelected(AccountabilityMonthStats month) {
    setState(() {
      _selectedMonth = month;
      var parsedMonth = DateFormat("yyyy/MM").parse(_selectedMonth!.month);
      _service = GetIt.I<CurrentMonthReportService>(param1: parsedMonth);
      _subscription = _service!.onChange.listen((_) {
        updateDateSelected(_selectedMonth!);
      });
    });
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
          buildReportHeader(context),
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
                    buildSection(
                      context,
                      "Receitas por Identificação",
                      Icons.savings_outlined,
                      FutureHandler(
                        future: _service!.incomesByIdentification(),
                        child: (data) => IdentificationsViewSection(
                          data: data,
                          onDataChanged: () {
                            updateDateSelected(_selectedMonth!);
                          },
                        ),
                      ),
                    ),
                    buildSection(
                      context,
                      "Despesas por Identificação",
                      Icons.money_off_outlined,
                      FutureHandler(
                        future: _service!.expensesByIdentification(),
                        child: (data) => IdentificationsViewSection(
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

  Widget buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Widget section,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Row(
          spacing: 10,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        section,
      ],
    );
  }

  Widget buildReportHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        spacing: 20,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: constraints.maxWidth < 850 ? 1 : 2,
            child: Row(
              spacing: 10,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFF262A34),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.dashboard,
                      color: Colors.purpleAccent,
                    ),
                  ),
                ),
                Text(
                  "Relatório mensal",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
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
          Flexible(
            child: MonthSelector(
              availableMonths: availableMonths,
              current: _selectedMonth!,
              onDateChanged: updateDateSelected,
            ),
          ),
        ],
      ),
    );
  }
}
