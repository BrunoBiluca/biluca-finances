import 'dart:async';

import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/components/table.dart';
import 'package:biluca_financas/common/extensions/string_extensions.dart';
import 'package:biluca_financas/components/base_dialog.dart';
import 'package:biluca_financas/components/base_page.dart';
import 'package:biluca_financas/components/mouse_back_button_listener.dart';
import 'package:biluca_financas/reports/components/future_handler.dart';
import 'package:biluca_financas/reports/components/month_selector.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/expenses_per_indentification.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/identifications_view_section.dart';
import 'package:biluca_financas/reports/monthly_report_v2/sections/accountability_by_identifications_section/incomes_per_identification.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/current_month_report.service.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/identification_rreport_info.dart';
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
  late DateTime _selectedDate;
  late CurrentMonthReportService _service;
  StreamSubscription? _subscription;

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
      _subscription = _service.onChange.listen((_) {
        updateDateSelected(_selectedDate);
      });
    });
  }

  void displayReportData() async {
    var date = DateFormat("MMMM yyyy", "pt_BR").format(_selectedDate).capitalize();
    var changedAccountability = false;

    Size size = MediaQuery.of(context).size;

    double width = size.width;
    double height = size.height;

    if (mounted) {
      await showDialog(
        context: context,
        builder: (context) => BaseDialog(
          title: "Registros de $date",
          content: SizedBox(
            width: width - 300,
            height: height - 300,
            child: BlocProvider(
              create: (_) => AccountabilityBloc(repo: _service.current)..add(FetchAccountabilityEntries()),
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
        updateDateSelected(_selectedDate);
      }
    }
  }

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SummaryValuesSection(),
                        const SizedBox(height: 20),
                        IncomesPerIdentification(service: _service),
                        const SizedBox(height: 20),
                        ExpensesPerIndentification(service: _service),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
