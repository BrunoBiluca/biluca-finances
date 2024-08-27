import 'dart:async';

import 'package:biluca_financas/reports/current_month_service.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:biluca_financas/reports/amount_by_identification_chart.dart';
import 'package:biluca_financas/reports/current_month_card.dart';
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
  late String _selectedMonth;
  late List<String> availableMonths = [];

  @override
  void initState() {
    super.initState();
    fillAvailableMonth();

    var lastIndex = availableMonths.length - 1;
    _selectedMonth = availableMonths[lastIndex];
    updateServices();
  }

  void updateServices() {
    _currentMonthService = GetIt.I<AccountabilityCurrentMonthService>(param1: _selectedMonth);
    _lastMonthService = GetIt.I<AccountabilityCurrentMonthService>(param1: getLastMonth());
  }

  String getLastMonth() {
    return availableMonths[availableMonths.indexOf(_selectedMonth) - 1];
  }

  void fillAvailableMonth() {
    var now = DateTime.now();
    availableMonths = [];
    for (var year = 2022; year <= now.year; year++) {
      for (var month = 1; month <= 12; month++) {
        if (month > now.month && year == now.year) {
          break;
        }
        availableMonths.add(formatMonth(month, year));
      }
    }
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            DropdownButton<String>(
              value: _selectedMonth,
              onChanged: (month) {
                setState(() {
                  _selectedMonth = month!;
                  updateServices();
                });
              },
              items: availableMonths.map((m) => DropdownMenuItem<String>(value: m, child: Text(m))).toList(),
            ),
            const SizedBox(height: 20),
            snapshot.data! == 0
                ? const Text(
                    "Não existem registros para esse mês",
                    key: Key("no_entries"),
                  )
                : monthInfo()
          ],
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
          CurrentMonthCard(service: _currentMonthService, lastMonthService: _lastMonthService),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
              future: getTotalByIdentification(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }

                var data = snapshot.data;
                if (data == null || data.isEmpty) {
                  return const Text("Nenhum item encontrado");
                }

                for (var g in data) {
                  print("${g.field.description} ${g.total}");
                }

                return SizedBox(
                  width: 1000,
                  height: 600,
                  child: AmountByIdentificationChart(accountabilityByIdentification: data),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
