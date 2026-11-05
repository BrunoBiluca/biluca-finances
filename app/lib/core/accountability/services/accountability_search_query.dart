class AccountabilitySearchQuery {
  static int? amountInCents(String query) {
    var normalized = query
        .trim()
        .replaceAll(RegExp(r'R\$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), '');
    if (normalized.startsWith('+') || normalized.startsWith('-')) {
      normalized = normalized.substring(1);
    }

    if (!RegExp(r'^\d[\d.,]*$').hasMatch(normalized)) {
      return null;
    }

    final lastComma = normalized.lastIndexOf(',');
    final lastDot = normalized.lastIndexOf('.');
    final separatorIndex = lastComma > lastDot ? lastComma : lastDot;
    if (separatorIndex == -1) {
      return int.parse(normalized) * 100;
    }

    final separator = normalized[separatorIndex];
    final wholePart = normalized.substring(0, separatorIndex);
    final fractionPart = normalized.substring(separatorIndex + 1);
    if (fractionPart.isEmpty || !RegExp(r'^\d+$').hasMatch(fractionPart)) {
      return null;
    }

    final hasOtherSeparator = normalized
        .substring(0, separatorIndex)
        .contains(separator == ',' ? '.' : ',');
    final isThousandsSeparator = !hasOtherSeparator && fractionPart.length == 3;
    if (fractionPart.length > 2 && !isThousandsSeparator) {
      return null;
    }

    final digits = normalized.replaceAll(RegExp(r'[.,]'), '');
    if (isThousandsSeparator) {
      final value = int.tryParse(digits);
      return value == null ? null : value * 100;
    }

    if (!RegExp(r'^\d+$').hasMatch(wholePart.replaceAll(RegExp(r'[.,]'), ''))) {
      return null;
    }

    final wholeValue = int.tryParse(wholePart.replaceAll(RegExp(r'[.,]'), ''));
    if (wholeValue == null) {
      return null;
    }
    final fractionValue = int.parse(fractionPart.padRight(2, '0'));
    return wholeValue * 100 + fractionValue;
  }
}
