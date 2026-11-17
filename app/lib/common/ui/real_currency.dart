import 'package:biluca_financas/app/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class RealCurrency extends StatelessWidget {
  final double number;
  final Color? color;

  const RealCurrency({required this.number, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    var appTheme = GetIt.I<ThemeManager>().getCurrentTheme(context);
    var textColor = color ?? (number < 0 ? appTheme.colors.negativeYield : appTheme.colors.positiveYield);

    return Text(
      NumberFormat.simpleCurrency(locale: "pt_Br").format(number),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
