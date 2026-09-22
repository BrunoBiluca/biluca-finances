import 'package:flutter/material.dart';

class YearlySummary {
  final double balance;
  final double avgBalance;
  final double totalExpenses;
  final double totalIncomes;
  final double avgExpenses;
  final double avgIncomes;
  final double peakIncome;
  final String peakIncomeMonth;
  final DateTimeRange range;

  YearlySummary({
    required this.balance,
    required this.avgBalance,
    required this.totalExpenses,
    required this.totalIncomes,
    required this.avgExpenses,
    required this.avgIncomes,
    required this.range,
    required this.peakIncome,
    required this.peakIncomeMonth,
  });
}
