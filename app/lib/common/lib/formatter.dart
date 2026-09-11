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

    var res = relationWithoutSign(relativePercentagem);
    var sign = v > 0 ? "+" : "";
    return "$sign$res";
  }

  static String relationWithoutSign(double relativePercentagem) {
    var v = relativePercentagem * 100;

    if (!v.isFinite) {
      return "?";
    }

    if (v.abs() <= 100) {
      return "${v.round().abs()}%";
    }

    var vTimes = v / 100;
    return "${vTimes.abs().toStringAsFixed(2)}x";
  }
}
