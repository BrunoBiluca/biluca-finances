import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RealInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    final formatter = NumberFormat.simpleCurrency(locale: "pt_Br");
    String newText = formatter.format(parse(newValue.text));
    return newValue.copyWith(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }

  double parse(String value) =>
      double.parse(value.replaceAll('.', '').replaceAll(",", "").replaceAll("R\$", "").trim()) / 100;
}
