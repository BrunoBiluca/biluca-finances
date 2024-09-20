import 'dart:async';

import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:biluca_financas/common/datetime_extensions.dart';
import 'package:biluca_financas/components/column_decorated_card.dart';
import 'package:biluca_financas/reports/components/single_value_card/single_value_card.dart';
import 'package:biluca_financas/reports/charts/identifications_by_barchart.dart';
import 'package:biluca_financas/reports/accountability_month_service.dart';
import 'package:biluca_financas/reports/charts/identifications_by_pie.dart';
import 'package:biluca_financas/reports/components/month_info_card.dart';
import 'package:biluca_financas/reports/components/month_selector.dart';
import 'package:biluca_financas/reports/current_month_report_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CurrentMonthReport extends StatefulWidget {
  const CurrentMonthReport({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentMonthReportState();
}

class _CurrentMonthReportState extends State<CurrentMonthReport> {
  late CurrentMonthReportService _service;

  late DateTime _selectedDate;

  @override
  void initState() {
    _selectedDate = DateTime.now();
    updateServices();
    super.initState();
  }

  void updateServices() {
    _service = CurrentMonthReportService(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _service.current.count(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        return Column(
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
                : Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headlines(),
                          const SizedBox(height: 20),
                          charts(),
                          const SizedBox(height: 20),
                          lastMonths(context),
                          const SizedBox(height: 20),
                          lastMonthsMeans(context)
                        ],
                      ),
                    ),
                  )
          ],
        );
      },
    );
  }

  Column lastMonths(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Últimos meses",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: Row(
            children: [
              Expanded(
                child: MonthInfoCard(service: _service.related, relatedMonthService: _service.current),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MonthInfoCard(
                  service: GetIt.I<AccountabilityMonthService>(
                    param1: _selectedDate.subtractMonth(2),
                  ),
                  relatedMonthService: _service.current,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MonthInfoCard(
                    service: GetIt.I<AccountabilityMonthService>(
                      param1: _selectedDate.subtractMonth(3),
                    ),
                    relatedMonthService: _service.current),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SizedBox charts() {
    return SizedBox(
      height: 500,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: ColumnDecoratedCard(
              title: "Receitas por identificação",
              future: _service.incomesByIdentification(),
              child: (d) => IdentificationsByPie(
                accountabilityByIdentification: d as List<GroupedBy<AccountabilityIdentification>>,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: ColumnDecoratedCard(
              title: "Gastos por identificação",
              future: _service.expensesByIdentification(),
              child: (d) => IdentificationsByBarChart(
                accountabilityByIdentification: d as List<GroupedBy<AccountabilityIdentification>>,
              ),
            ),
          )
        ],
      ),
    );
  }

  SizedBox headlines() {
    return SizedBox(
      height: 150,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: reportFuture(
              _service.summaryBalance(),
              (d) => SingleValueCard(
                title: "Balanço",
                currentValue: d["balance"],
                relatedValue: d["related"],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: reportFuture(
              _service.summaryIncomes(),
              (d) => SingleValueCard(
                title: "Receitas",
                currentValue: d["incomes"],
                relatedValue: d["related"],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: reportFuture(
              _service.summaryExpenses(),
              (d) => SingleValueCard(
                title: "Despesas",
                currentValue: d["expenses"],
                relatedValue: d["related"],
                lessIsPositite: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget reportFuture(Future<dynamic> future, Widget Function(dynamic) child) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        var result = snapshot.data!;
        return child(result);
      },
    );
  }

  Widget lastMonthsMeans(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Médias dos últimos meses",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 20),
        reportFuture(
          _service.getMeansByIdentification(),
          (data) {
            var d = data.values.toList();

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                mainAxisExtent: 150.0,
              ),
              shrinkWrap: true,
              itemCount: d.length,
              itemBuilder: (context, index) {
                var item = d[index];

                return SingleValueCard(
                  title: item["field"],
                  currentValue: item["mean"] != null ? item["mean"]! : 0,
                  relatedValue: item["current"] != null ? item["current"]! : 0,
                  lessIsPositite: item["field"] == "Despesas",
                );
              },
            );
          },
        )
      ],
    );
  }
}
