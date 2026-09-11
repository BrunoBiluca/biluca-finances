import 'dart:async';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/components/base_dialog.dart';
import 'package:biluca_financas/core/accountability_stats/models/accountability_month_stats.dart';
import 'package:biluca_financas/core/accountability_stats/services/accountability_stats_service.dart';
import 'package:biluca_financas/reports/components/future_handler.dart';
import 'package:biluca_financas/reports/components/month_selector.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/expenses_per_indentification.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/incomes_per_identification.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/summary_last_months/summary_last_months_section.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/current_month_report.service.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/monthly_report_service.provider.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/summary_values_section/summary_values_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class MonthlyReportV2 extends StatefulWidget {
  const MonthlyReportV2({super.key});

  @override
  State<StatefulWidget> createState() => _MonthlyReportV2State();
}

class _MonthlyReportV2State extends State<MonthlyReportV2> {
  List<AccountabilityMonthStats> availableMonths = [];
  AccountabilityMonthStats? _selectedMonth;
  CurrentMonthReportService? _service;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    fillMonths();
  }

  void fillMonths() async {
    var result = await GetIt.I<AccountabilityStatsService>().getAllMonthsWithAccountability(fillBlanks: true);
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
      service: _service!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MonthSelector(
                availableMonths: availableMonths,
                current: _selectedMonth!,
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
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _selectedMonth!.entriesCount == 0
                ? const Center(child: Text("Nenhum registro encontrado"))
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SummaryValuesSection(),
                        const SizedBox(height: 60),
                        SummaryLastMonthsSection(),
                        const SizedBox(height: 60),
                        IncomesPerIdentification(service: _service!),
                        const SizedBox(height: 60),
                        ExpensesPerIndentification(service: _service!),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
