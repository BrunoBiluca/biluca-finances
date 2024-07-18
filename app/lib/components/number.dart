import 'package:biluca_financas/common/formatter.dart';
import 'package:flutter/material.dart';

class Number extends StatelessWidget {
  final double number;
  const Number({required this.number, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(Formatter.number(number));
  }
}
