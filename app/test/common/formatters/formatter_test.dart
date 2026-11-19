import 'package:biluca_financas/common/formatters/formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Formatter.dateTime', () {
    test('apresenta o instante UTC no fuso local da máquina', () {
      final instant = DateTime.utc(2026, 5, 6, 14, 30);

      final expected = DateFormat('dd/MM/yyyy HH:mm').format(instant.toLocal());

      expect(Formatter.dateTime(instant), expected);
    });

    test('mantém o texto de um horário já local', () {
      final local = DateTime(2026, 5, 6, 14, 30);

      expect(Formatter.dateTime(local), '06/05/2026 14:30');
    });

    test('difere da representação em UTC quando o fuso local não é UTC', () {
      final instant = DateTime.utc(2026, 5, 6, 14, 30);
      final expected = DateFormat('dd/MM/yyyy HH:mm').format(instant.toLocal());

      expect(Formatter.dateTime(instant), expected);

      if (instant.toLocal() != instant) {
        expect(Formatter.dateTime(instant), isNot('06/05/2026 14:30'));
      }
    });
  });
}
