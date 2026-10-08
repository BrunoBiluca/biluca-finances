import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:biluca_financas/common/extensions/color_extensions.dart';
import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:biluca_financas/common/ui/hover_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MonthSummaryCard extends StatefulWidget {
  final String title;
  final double balance;
  final double incomes;
  final double expenses;
  final Color color;
  final String label;

  const MonthSummaryCard({
    super.key,
    required this.title,
    this.color = Colors.white,
    required this.label,
    required this.balance,
    required this.incomes,
    required this.expenses,
  });

  @override
  State<MonthSummaryCard> createState() => _MonthSummaryCardState();
}

class _MonthSummaryCardState extends State<MonthSummaryCard> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    var appTheme = GetIt.I<ThemeManager>();
    var currTheme = appTheme.getCurrentTheme(context);

    return HoverWrapper(
      onHover: (value) => setState(() => isHover = value),
      child: Card(
        color: isHover ? Theme.of(context).cardColor.addBrightness(10) : Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 20,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Icon(Icons.calendar_month, color: widget.color),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.color.addBrightness(-100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                      child: Row(
                        spacing: 4,
                        children: [
                          Text(
                            widget.label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: widget.color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Saldo Líquido".toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        Formatter.value(widget.balance),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: widget.balance > 0
                                  ? currTheme.colors.positiveYieldAlt
                                  : currTheme.colors.negativeYield,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Receitas",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              Formatter.value(widget.incomes),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: currTheme.colors.positiveYield,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Despesas",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              Formatter.value(widget.expenses),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: currTheme.colors.negativeYield,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Economia do mês", style: Theme.of(context).textTheme.bodySmall),
                      widget.balance < 0
                          ? Text("0% retido",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: currTheme.colors.negativeYield,
                                    fontWeight: FontWeight.bold,
                                  ))
                          : Text(
                              "${Formatter.relationWithoutSign(widget.balance / widget.incomes)} retido",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: currTheme.colors.positiveYield,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ],
                  ),
                  LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 10,
                    value: widget.balance / widget.incomes,
                    color: widget.balance > 0 ? currTheme.colors.positiveYield : currTheme.colors.negativeYield,
                    backgroundColor: currTheme.colors.negativeYield,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
