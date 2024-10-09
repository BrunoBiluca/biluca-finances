import 'package:biluca_financas/formatter.dart';
import 'package:biluca_financas/common/extensions/string_extensions.dart';
import 'package:biluca_financas/components/base_decorated_card.dart';
import 'package:biluca_financas/reports/components/single_value_card/values_relation_text.dart';
import 'package:biluca_financas/reports/accountability_month_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthInfoCard extends StatelessWidget {
  final AccountabilityMonthService service;
  final AccountabilityMonthService relatedMonthService;
  const MonthInfoCard({
    super.key,
    required this.service,
    required this.relatedMonthService,
  });

  String formatDate(int year, int month) => DateFormat("MMMM yyyy", "pt_BR").format(DateTime(year, month)).capitalize();

  String title() {
    var str = relatedMonthService.currentMonth.split("/");
    return formatDate(int.parse(str[1]), int.parse(str[0]));
  }

  @override
  Widget build(BuildContext context) {
    return BaseDecoratedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title(),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
              future: Future.sync(() async {
                var incomes = await service.getIncomes();
                var expenses = await service.getExpenses();

                var relIncomes = await relatedMonthService.getIncomes();
                var relExpenses = await relatedMonthService.getExpenses();

                return (
                  incomes,
                  expenses,
                  relIncomes,
                  relExpenses,
                );
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }

                var result = snapshot.data!;

                if (result.$3 == 0 && result.$4 == 0) {
                  return Text(
                    "Sem registros para esse mês",
                    style: Theme.of(context).textTheme.displaySmall,
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  Formatter.value(result.$3),
                                  key: const Key("receitas"),
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ValuesRelationText.withValues(
                                result.$1,
                                result.$3,
                                key: const Key("receitas relativas"),
                              )
                            ],
                          ),
                          Text(
                            "Receitas",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  Formatter.value(result.$4),
                                  key: const Key("despesas"),
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ValuesRelationText.withValues(
                                result.$2,
                                result.$4,
                                key: const Key("despesas relativas"),
                                lessIsPositite: true,
                              )
                            ],
                          ),
                          Text(
                            "Despesas",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
