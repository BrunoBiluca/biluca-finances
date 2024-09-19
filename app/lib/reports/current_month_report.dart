import 'dart:async';

import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:biluca_financas/common/datetime_extensions.dart';
import 'package:biluca_financas/components/base_decorated_card.dart';
import 'package:biluca_financas/reports/components/single_value_card/single_value_card.dart';
import 'package:biluca_financas/reports/charts/identifications_by_barchart.dart';
import 'package:biluca_financas/reports/accountability_month_service.dart';
import 'package:biluca_financas/reports/charts/identifications_by_pie.dart';
import 'package:biluca_financas/reports/components/month_info_card.dart';
import 'package:biluca_financas/reports/components/month_selector.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';

class CurrentMonthReport extends StatefulWidget {
  const CurrentMonthReport({super.key});

  @override
  State<StatefulWidget> createState() => _CurrentMonthReportState();
}

class _CurrentMonthReportState extends State<CurrentMonthReport> {
  late AccountabilityMonthService _currentMonthService;
  late AccountabilityMonthService _lastMonthService;

  late DateTime _selectedDate;

  @override
  void initState() {
    _selectedDate = DateTime.now();
    updateServices();
    super.initState();
  }

  void updateServices() {
    _currentMonthService = GetIt.I<AccountabilityMonthService>(
      param1: formatMonth(_selectedDate.month, _selectedDate.year),
    );

    _lastMonthService = getMonthService(1);
  }

  AccountabilityMonthService getMonthService(int monthBefore) {
    var lastMonth = _selectedDate.subtractMonth(monthBefore);
    return GetIt.I<AccountabilityMonthService>(
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
                      child: monthInfo(context),
                    ),
                  )
          ],
        );
      },
    );
  }

  Widget monthInfo(BuildContext context) {
    return Column(
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
                child: MonthInfoCard(service: _lastMonthService, relatedMonthService: _currentMonthService),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MonthInfoCard(service: getMonthService(2), relatedMonthService: _currentMonthService),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MonthInfoCard(service: getMonthService(3), relatedMonthService: _currentMonthService),
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
          identificationsChart(
            "Receitas por identificação",
            1,
            (data) => IdentificationsByPie(
              accountabilityByIdentification: data.where((i) => i.total! > 0).toList(),
            ),
          ),
          const SizedBox(width: 20),
          identificationsChart(
            "Gastos por identificação",
            2,
            (data) => IdentificationsByBarChart(
              accountabilityByIdentification: data.where((i) => i.total! < 0).toList(),
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
          summaryCard(
            "Balanço",
            Future.sync(() async => (
                  await _currentMonthService.getBalance(),
                  await _lastMonthService.getBalance(),
                )),
          ),
          const SizedBox(width: 20),
          summaryCard(
            "Receitas",
            Future.sync(() async => (
                  await _currentMonthService.getIncomes(),
                  await _lastMonthService.getIncomes(),
                )),
          ),
          const SizedBox(width: 20),
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
            relatedValue: result.$2,
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

  Widget lastMonthsMeans(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Médias dos últimos meses",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 20),
        FutureBuilder(
          future: Future.sync(
            () async {
              var identifications = await _lastMonthService.getAccumulatedMeansByIdentification();
              var values = {};
              for (var i in identifications) {
                values[i.field.description] = {"field": i.field, "mean": i, "current": null};
              }

              var currIdentifications = await _currentMonthService.getTotalByIdentification();
              for (var i in currIdentifications) {
                if (!values.containsKey(i.field.description)) {
                  values[i.field.description] = {"field": i.field, "mean": null, "current": i};
                } else {
                  values[i.field.description]["current"] = i;
                }
              }

              return values;
            },
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              print(snapshot.error);
              print(snapshot.stackTrace);
            }

            if (snapshot.data == null) {
              return Container();
            }
            var data = snapshot.data!.values.toList();
            print(data.length);

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                mainAxisExtent: 150.0,
              ),
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                var item = data[index];

                return SingleValueCard(
                  title: item["field"].description,
                  currentValue: item["mean"] != null ? item["mean"].mean! : 0,
                  relatedValue: item["current"] != null ? item["current"].total! : 0,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
