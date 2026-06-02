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
import 'package:biluca_financas/reports/monthly_report_v2/components/values_comparison_small.dart';
import 'package:biluca_financas/reports/monthly_report_v2/services/identification_rreport_info.dart';
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
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconHighlight(
                    bgColor: widget.idReportInfo.identification.color,
                    borderColor: widget.idReportInfo.identification.color,
                    txtColor: widget.idReportInfo.identification.color.adaptByLuminance(),
                    icon: widget.idReportInfo.identification.icon,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.idReportInfo.identification.description,
                          style: Theme.of(context).textTheme.displaySmall!,
                        ),
                        Text(
                          Formatter.value(widget.idReportInfo.current),
                          style: Theme.of(context).textTheme.displayLarge!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ValuesComparisonSmall(
                    ValuesRelation(
                      widget.idReportInfo.current,
                      widget.idReportInfo.related,
                      lessIsPositite:
                          widget.idReportInfo.identification.type == AccountabilityIdentificationType.expense,
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
