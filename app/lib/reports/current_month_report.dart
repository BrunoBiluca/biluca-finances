import 'dart:async';

import 'package:biluca_financas/components/base_decorated_card.dart';
import 'package:biluca_financas/components/single_value_card.dart';
import 'package:biluca_financas/reports/amount_by_identification_chart.dart';
import 'package:biluca_financas/reports/current_month_service.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:biluca_financas/reports/identifications_by_pie.dart';
import 'package:biluca_financas/reports/month_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CurrentMonthReport extends StatefulWidget {
  const CurrentMonthReport({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentMonthReportState();
}

class _CurrentMonthReportState extends State<CurrentMonthReport> {
  late AccountabilityCurrentMonthService _currentMonthService;
  late AccountabilityCurrentMonthService _lastMonthService;

  late DateTime _selectedDate;

  @override
  void initState() {
    _selectedDate = DateTime.now();
    updateServices();
    super.initState();
  }

  void updateServices() {
    var lastMonth = _selectedDate.subtract(Duration(days: _selectedDate.day + 1));
    _currentMonthService = GetIt.I<AccountabilityCurrentMonthService>(
      param1: formatMonth(_selectedDate.month, _selectedDate.year),
    );
    _lastMonthService = GetIt.I<AccountabilityCurrentMonthService>(
      param1: formatMonth(lastMonth.month, lastMonth.year),
    );
  }

  String formatMonth(int month, int year) {
    return "${month < 10 ? '0' : ''}$month/$year";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _currentMonthService.count(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MonthSelector(
                current: _selectedDate,
                onDateChanged: (date) => setState(
                  () {
                    _selectedDate = date;
                    updateServices();
                  },
                ),
              ),
              const SizedBox(height: 20),
              snapshot.data! == 0
                  ? const Text(
                      "Não existem registros para esse mês",
                      key: Key("no_entries"),
                    )
                  : monthInfo()
            ],
          ),
        );
      },
    );
  }

  Widget monthInfo() {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              children: [
                summaryCard(
                  "Balanço",
                  Future.sync(() async => (
                        await _currentMonthService.getBalance(),
                        await _lastMonthService.getBalance(),
                      )),
                ),
                SizedBox(width: 20),
                summaryCard(
                  "Receitas",
                  Future.sync(() async => (
                        await _currentMonthService.getIncomes(),
                        await _lastMonthService.getIncomes(),
                      )),
                ),
                SizedBox(width: 20),
                summaryCard(
                  "Despesas",
                  Future.sync(() async => (
                        await _currentMonthService.getExpenses(),
                        await _lastMonthService.getExpenses(),
                      )),
                  lessIsPositite: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 500,
            child: Row(
              children: [
                identificationsChart(
                  "Receitas por identificação",
                  1,
                  (data) => IdentificationsByPie(
                    accountabilityByIdentification: data.where((i) => i.total > 0).toList(),
                  ),
                ),
                SizedBox(width: 20),
                identificationsChart(
                  "Gastos por identificação",
                  2,
                  (data) => AmountByIdentificationChart(
                    accountabilityByIdentification: data.where((i) => i.total < 0).toList(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget summaryCard(String title, Future<(double, double)> computation, {bool lessIsPositite = false}) {
    return Expanded(
      flex: 1,
      child: FutureBuilder(
        future: computation,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          var result = snapshot.data!;
          return SingleValueCard(
            title: title,
            currentValue: result.$1,
            lastValue: result.$2,
            lessIsPositite: lessIsPositite,
          );
        },
      ),
    );
  }

  Widget identificationsChart(
    String title,
    int flex,
    Widget Function(List<GroupedBy<AccountabilityIdentification>>) identificationsCallback,
  ) {
    return Expanded(
      flex: flex,
      child: FutureBuilder(
        future: Future.sync(
          () async => (await _currentMonthService.getTotalByIdentification())
            ..addAll(await _lastMonthService.getTotalByIdentification()),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }

          var data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Text("Nenhum item encontrado");
          }

          return BaseDecoratedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 20),
                Expanded(child: identificationsCallback(data)),
              ],
            ),
          );
        },
      ),
    );
  }
}
