import 'dart:async';

import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/common/data/grouped_by.dart';
import 'package:biluca_financas/common/extensions/datetime_extensions.dart';
import 'package:biluca_financas/components/column_decorated_card.dart';
import 'package:biluca_financas/reports/components/icon_highlight.dart';
import 'package:biluca_financas/reports/components/single_value_card/single_value_card.dart';
import 'package:biluca_financas/reports/charts/identifications_by_barchart.dart';
import 'package:biluca_financas/reports/accountability_month_service.dart';
import 'package:biluca_financas/reports/charts/identifications_by_pie.dart';
import 'package:biluca_financas/reports/components/month_info_card.dart';
import 'package:biluca_financas/reports/components/month_selector.dart';
import 'package:biluca_financas/reports/current_month_report_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        FutureBuilder(
          future: _service.current.count(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }

            if (snapshot.data! == 0) {
              return const Text(
                "Não existem registros para esse mês",
                key: Key("no_entries"),
              );
            }

            return Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headlines(),
                    const SizedBox(height: 100),
                    lastMonths(context),
                    const SizedBox(height: 100),
                    lastMonthsMeans(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget headlines() {
    return StaggeredGrid.count(
      crossAxisCount: 3,
      crossAxisSpacing: 20,
      mainAxisSpacing: 40,
      children: [
        StaggeredGridTile.extent(
          crossAxisCellCount: 1,
          mainAxisExtent: 150,
          child: reportFuture(
            _service.summaryBalance(),
            (d) => SingleValueCard(
              title: "Balanço",
              currentValue: d["balance"],
              side: d["balance"] > 0
                  ? const IconHighlight(
                      bgColor: Color(0xFF122622),
                      borderColor: Color(0xFF232428),
                      txtColor: Color(0xFF43C67C),
                      icon: FontAwesomeIcons.plus,
                    )
                  : const IconHighlight(
                      bgColor: Color(0xFF24141B),
                      borderColor: Color(0xFF232428),
                      txtColor: Color(0xFFF54149),
                      icon: FontAwesomeIcons.minus,
                    ),
            ),
          ),
        ),
        StaggeredGridTile.extent(
          crossAxisCellCount: 1,
          mainAxisExtent: 150,
          child: reportFuture(
            _service.summaryIncomes(),
            (d) => SingleValueCard(
              title: "Receitas",
              currentValue: d["incomes"],
              relatedValue: d["related"],
            ),
          ),
        ),
        StaggeredGridTile.extent(
          crossAxisCellCount: 1,
          mainAxisExtent: 150,
          child: reportFuture(
            _service.summaryExpenses(),
            (d) => SingleValueCard(
              title: "Despesas",
              currentValue: d["expenses"],
              relatedValue: d["related"],
              lessIsPositite: true,
            ),
          ),
        ),
        StaggeredGridTile.extent(
          crossAxisCellCount: 1,
          mainAxisExtent: 500,
          child: ColumnDecoratedCard(
            title: "Receitas por identificação",
            future: _service.incomesByIdentification(),
            child: (d) => IdentificationsByPie(
              accountabilityByIdentification: d as List<GroupedBy<AccountabilityIdentification>>,
            ),
          ),
        ),
        StaggeredGridTile.extent(
          crossAxisCellCount: 2,
          mainAxisExtent: 500,
          child: ColumnDecoratedCard(
            title: "Gastos por identificação",
            future: _service.expensesByIdentification(),
            child: (d) => IdentificationsByBarChart(accountabilityByIdentification: d),
          ),
        ),
      ],
    );
  }

  Widget reportFuture(Future<dynamic> future, Widget Function(dynamic) child) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data == null) {
          return const Text("Nenhum item encontrado");
        }

        var result = snapshot.data!;
        return child(result);
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
                child: MonthInfoCard(service: _service.current, relatedMonthService: _service.related),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MonthInfoCard(
                  service: _service.current,
                  relatedMonthService: GetIt.I<AccountabilityMonthService>(
                    param1: _selectedDate.subtractMonth(2),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MonthInfoCard(
                  service: _service.current,
                  relatedMonthService: GetIt.I<AccountabilityMonthService>(
                    param1: _selectedDate.subtractMonth(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget lastMonthsMeans(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Médias dos últimos 12 meses",
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
                crossAxisSpacing: 30.0,
                mainAxisSpacing: 40.0,
                mainAxisExtent: 150.0,
              ),
              shrinkWrap: true,
              itemCount: d.length,
              itemBuilder: (context, index) {
                var item = d[index];
                var mean = item["mean"] != null ? item["mean"]! : 0.0;
                var current = item["current"] != null ? item["current"]! : 0.0;

                return SingleValueCard(
                  title: item["desc"],
                  currentValue: current,
                  relatedValue: mean,
                  displayValue: mean,
                  lessIsPositite: mean < 0,
                  side: item["field"] != null
                      ? IconHighlight(
                          bgColor: item["field"].color,
                          borderColor: const Color(0xFF122622),
                          txtColor: (item["field"].color as Color).adaptByLuminance(),
                          icon: Icons.photo_size_select_actual_outlined,
                        )
                      : null,
                );
              },
            );
          },
        )
      ],
    );
  }
}
