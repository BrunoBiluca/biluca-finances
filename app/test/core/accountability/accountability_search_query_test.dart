import 'package:biluca_financas/core/accountability/services/accountability_search_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses Brazilian currency notation', () {
    expect(AccountabilitySearchQuery.amountInCents('R\$ 1.234,56'), 123456);
  });

  test('parses simple integer and decimal values', () {
    expect(AccountabilitySearchQuery.amountInCents('22'), 2200);
    expect(AccountabilitySearchQuery.amountInCents('22.5'), 2250);
  });

  test('parses negative values by their absolute amount', () {
    expect(AccountabilitySearchQuery.amountInCents('-R\$ 22,00'), 2200);
  });

  test('does not parse mixed text as a monetary value', () {
    expect(AccountabilitySearchQuery.amountInCents('Market 22,00'), isNull);
  });
}
