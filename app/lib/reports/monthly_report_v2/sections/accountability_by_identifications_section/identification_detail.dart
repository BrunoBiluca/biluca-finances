import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/components/table.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/components/base_dialog.dart';
import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/reports/components/icon_highlight.dart';
import 'package:biluca_financas/reports/models/values_relation.dart';
import 'package:biluca_financas/reports/components/values_comparison_small.dart';
import 'package:biluca_financas/reports/components/values_comparison_full_text.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/identification_report_info.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/monthly_report_service.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IdentificationDetail extends StatefulWidget {
  final IdentificationReportInfo idReportInfo;

  const IdentificationDetail(this.idReportInfo, {super.key});

  @override
  State<IdentificationDetail> createState() => _IdentificationDetailState();
}

class _IdentificationDetailState extends State<IdentificationDetail> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    var id = widget.idReportInfo.identification;
    var current = widget.idReportInfo.current;
    var lastMonth = widget.idReportInfo.related;
    var avgRecentMonts = widget.idReportInfo.avgRecentMonts;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: InkWell(
          onTap: () => displayReportData(context),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isHover ? Color.fromARGB(255, 53, 57, 71) : Theme.of(context).colorScheme.primary,
              border: Border.all(color: Theme.of(context).colorScheme.outline, width: 4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconHighlight(
                    bgColor: id.color,
                    borderColor: id.color,
                    txtColor: id.color.adaptByLuminance(),
                    icon: id.icon,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          id.description,
                          style: Theme.of(context).textTheme.displaySmall!,
                        ),
                        Text(
                          Formatter.value(current),
                          style: Theme.of(context).textTheme.displayLarge!,
                        ),
                        const SizedBox(height: 20),
                        ValuesComparisonFullText.from(
                          current,
                          avgRecentMonts,
                          id.type == AccountabilityIdentificationType.expense,
                          suffix: "em relação aos últimos 12 meses",
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            text: "Representa ",
                            style: Theme.of(context).textTheme.bodySmall!,
                            children: [
                              TextSpan(
                                text: Formatter.relationWithoutSign(widget.idReportInfo.currentPercentage),
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              TextSpan(
                                text: id.type == AccountabilityIdentificationType.expense
                                    ? " de despesas"
                                    : " de receitas",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 36,
                    child: ValuesComparisonSmall(
                      ValuesRelation(
                        current,
                        lastMonth,
                        lessIsPositite: id.type == AccountabilityIdentificationType.expense,
                      ),
                      tooltipSuffix: "mês anterior",
                    ),
                  ),
                ],
              ),
            ),
          ),
          onHover: (val) {
            setState(() {
              isHover = val;
            });
          },
        ),
      ),
    );
  }

  void displayReportData(BuildContext context) async {
    var changedAccountability = false;

    Size size = MediaQuery.of(context).size;

    double width = size.width;
    double height = size.height;

    if (mounted) {
      var service = MonthlyReportServiceProvider.of(context);
      await showDialog(
        context: context,
        builder: (context) => BaseDialog(
          title: "Registros de ${widget.idReportInfo.identification.description}",
          content: SizedBox(
            width: width - 300,
            height: height - 300,
            child: BlocProvider(
              create: (_) => AccountabilityBloc(repo: service.current)
                ..add(FetchAccountabilityEntries(
                  identification: widget.idReportInfo.identification,
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
}
