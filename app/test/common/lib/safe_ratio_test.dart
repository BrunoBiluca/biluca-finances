import 'package:biluca_financas/common/lib/safe_ratio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('safeRatio', () {
    test('returns null when the base is zero', () {
      expect(safeRatio(10, 0), isNull);
      expect(safeRatio(0, 0), isNull);
    });

    test('returns the ratio when the base is positive', () {
      expect(safeRatio(10, 4), 2.5);
      expect(safeRatio(0, 4), 0);
    });

    test('returns the ratio when the base is negative', () {
      expect(safeRatio(10, -4), -2.5);
      expect(safeRatio(-10, -4), 2.5);
    });

    test('handles decimal values', () {
      expect(safeRatio(1, 3), closeTo(0.3333, 0.0001));
    });
  });
}
