import 'package:biluca_financas/app/accountability_monthly_report/monthly_report_service.provider.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/identifications_barchart.dart';
import 'package:biluca_financas/app/accountability_monthly_report/widgets/identifications_percentage_chart.dart';
import 'package:biluca_financas/app/accountability_table/accountability_table.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/base_dialog.dart';
import 'package:biluca_financas/common/ui/reports/summary_value_card/summary_value_card.dart';
import 'package:biluca_financas/common/ui/reports/values_comparison_full_text.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/core/accountability_monthly_report/models/identification_report_info.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class IdentificationsViewSection extends StatelessWidget {
  final List<IdentificationReportInfo> data;
  final Function onDataChanged;

  const IdentificationsViewSection({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    var sortedData = data.sorted((a, b) => b.current.abs().compareTo(a.current.abs()));

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        spacing: 10,
        children: [
          StaggeredGrid.count(
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: constraints.maxWidth < 850 ? 1 : 3,
            children: sortedData
                .map(
                  (e) => StaggeredGridTile.extent(
                    mainAxisExtent: 230,
                    crossAxisCellCount: 1,
                    child: GestureDetector(
                      onTap: () => displayReportData(context, e),
                      child: SummaryValueCard(
                        title: e.identification.description,
                        value: e.current.abs(),
                        subInfo: Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValuesComparisonFullText.from(
                              e.current,
                              e.avgRecentMonts,
                              false,
                              suffix: "em relação aos últimos 12 meses",
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 6,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Participação no total", style: Theme.of(context).textTheme.bodySmall),
                                    Text(
                                      Formatter.relationWithoutSign(e.participationInTotal),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: e.identification.color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    )
                                  ],
                                ),
                                LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(10),
                                  minHeight: 6,
                                  value: e.participationInTotal,
                                  color: e.identification.color,
                                  backgroundColor: Colors.grey.shade800,
                                ),
                              ],
                            )
                          ],
                        ),
                        color: e.identification.color,
                        icon: e.identification.icon,
                        iconColor: e.identification.color,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(
            height: 500,
            width: double.maxFinite,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: Column(
                        spacing: 20,
                        children: [
                          Row(
                            spacing: 10,
                            children: [
                              Icon(
                                Icons.bar_chart,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              Text(
                                "Comportamento das identificações",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Expanded(child: IdentificationsBarChart(data: sortedData)),
                        ],
                      ),
                    ),
                    IdentificationsPercentageChart(data: sortedData)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void displayReportData(BuildContext context, IdentificationReportInfo report) async {
    var changedAccountability = false;

    Size size = MediaQuery.of(context).size;

    double width = size.width;
    double height = size.height;

    var service = MonthlyReportServiceProvider.of(context);
    await showDialog(
      context: context,
      builder: (context) => BaseDialog(
        title: "Registros de ${report.identification.description}",
        content: SizedBox(
          width: width - 300,
          height: height - 300,
          child: BlocProvider(
            create: (_) => AccountabilityBloc(repo: service.current)
              ..add(FetchAccountabilityEntries(
                identification: report.identification,
              )),
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
      service.emitRefresh();
    }
  }
}
