import 'package:biluca_financas/core/accountability/models/accountability_entry_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects whether any criterion is filled', () {
    expect(AccountabilityEntryFilter.empty.isEmpty, isTrue);
    expect(AccountabilityEntryFilter.empty.isNotEmpty, isFalse);

    expect(
      const AccountabilityEntryFilter(minValue: 0).isNotEmpty,
      isTrue,
    );
    expect(
      AccountabilityEntryFilter(startDate: DateTime(2026, 1, 1)).isNotEmpty,
      isTrue,
    );
    expect(
      AccountabilityEntryFilter(endDate: DateTime(2026, 1, 31)).isNotEmpty,
      isTrue,
    );
    expect(
      const AccountabilityEntryFilter(maxValue: 10).isNotEmpty,
      isTrue,
    );
  });

  test('expands the period to the whole days', () {
    final filter = AccountabilityEntryFilter(
      startDate: DateTime(2026, 1, 5, 18, 30),
      endDate: DateTime(2026, 1, 9, 3, 15),
    );

    expect(filter.periodStart, DateTime(2026, 1, 5));
    expect(
      filter.periodEnd,
      DateTime(2026, 1, 9, 23, 59, 59, 999),
    );
  });

  test('keeps the period bounds empty when no date is informed', () {
    const filter = AccountabilityEntryFilter(minValue: 10);

    expect(filter.periodStart, isNull);
    expect(filter.periodEnd, isNull);
  });
}
