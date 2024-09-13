import 'dart:async';

import 'package:biluca_financas/components/single_value_card.dart';
import 'package:biluca_financas/reports/current_month_service.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
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

  Future<List<GroupedBy<AccountabilityIdentification>>> getTotalByIdentification() async {
    var result = await _currentMonthService.getTotalByIdentification();
    result.addAll(await _lastMonthService.getTotalByIdentification());
    return result;
  }

  Expanded monthInfo() {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              card(
                "Balanço",
                Future.sync(() async => (
                      await _currentMonthService.getBalance(),
                      await _lastMonthService.getBalance(),
                    )),
              ),
              SizedBox(width: 20),
              card(
                "Receitas",
                Future.sync(() async => (
                      await _currentMonthService.getIncomes(),
                      await _lastMonthService.getIncomes(),
                    )),
              ),
              SizedBox(width: 20),
              card(
                "Despesas",
                Future.sync(() async => (
                      await _currentMonthService.getIncomes(),
                      await _lastMonthService.getIncomes(),
                    )),
              ),
            ],
          ),
          // const SizedBox(height: 20),
          // Expanded(
          //   child: FutureBuilder(
          //     future: getTotalByIdentification(),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState != ConnectionState.done) {
          //         return const CircularProgressIndicator();
          //       }

          //       var data = snapshot.data;
          //       if (data == null || data.isEmpty) {
          //         return const Text("Nenhum item encontrado");
          //       }

          //       for (var g in data) {
          //         print("${g.field.description} ${g.total}");
          //       }

          //       return SizedBox(
          //         width: 1000,
          //         height: 600,
          //         child: AmountByIdentificationChart(accountabilityByIdentification: data),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget card(String title, Future<(double, double)> computation) {
    return Expanded(
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
          );
        },
      ),
    );
  }
}
