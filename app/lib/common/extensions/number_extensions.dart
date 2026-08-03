import 'dart:math';

import 'package:collection/collection.dart';

double cast(dynamic v) => v is int ? v.toDouble() : v;

extension DoubleExtension on double {
  double subtractP(double percentage) => this - this * percentage;
}

extension DoubleListExtension on Iterable<double> {
  double get standardDeviation {
    double mean = average;
    double squaresSum = 0.0;
    for (double value in this) {
      squaresSum += (value - mean) * (value - mean);
    }
    double variancia = squaresSum / (length - 1);
    return sqrt(variancia);
  }
}
