import 'package:biluca_financas/app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RealCurrency extends StatelessWidget {
  final double number;
  final Color? color;

  const RealCurrency({required this.number, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    var textColor = color ?? (number < 0 ? appColors.negativeYield : appColors.positiveYield);

    return Text(
      NumberFormat.simpleCurrency(locale: "pt_Br").format(number),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
