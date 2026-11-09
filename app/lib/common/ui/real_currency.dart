import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RealCurrency extends StatelessWidget {
  final double number;
  final Color? color;

  const RealCurrency({required this.number, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      NumberFormat.simpleCurrency(locale: "pt_Br").format(number),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
    );
  }
}
