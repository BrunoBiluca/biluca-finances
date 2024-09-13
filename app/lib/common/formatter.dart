import 'package:intl/intl.dart';

class Formatter {
  static String date(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

  static String number(double number) =>
      NumberFormat.decimalPatternDigits(locale: "pt_BR", decimalDigits: 2).format(number);

  static String value(double value) => "R\$ ${number(value)}";

  static String percent(double number) => Formatter.number(number * 100);

  static String relation(double relativePercentagem) {
    var v = relativePercentagem * 100;

    if (!v.isFinite) {
      return "?";
    }

    var sign = v > 0 ? "+" : "";

    if (v.abs() < 100) {
      return "$sign${v.round()}%";
    }

    var vTimes = v / 100 + 1;
    if (vTimes.truncate() == vTimes) {
      return "$sign${vTimes.truncate()}x";
    }
    return "$sign${vTimes}x";
  }
}
