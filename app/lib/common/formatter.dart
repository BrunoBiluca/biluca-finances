import 'package:intl/intl.dart';

class Formatter {
  static String date(DateTime date) =>  DateFormat('dd/MM/yyyy').format(date);

  static String number(double number) => NumberFormat.decimalPatternDigits(decimalDigits: 2).format(number);
}
