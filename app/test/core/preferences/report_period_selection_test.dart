import 'package:biluca_financas/core/accountability_stats/models/accountability_month_stats.dart';
import 'package:biluca_financas/core/accountability_stats/models/accountability_year_stats.dart';
import 'package:biluca_financas/core/preferences/report_period_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final months = [
    AccountabilityMonthStats('2026/01', 1),
    AccountabilityMonthStats('2026/02', 2),
    AccountabilityMonthStats('2026/03', 0),
  ];

  test('restores the saved month when it is available', () {
    final selected = ReportPeriodSelection.resolveMonth(
      availableMonths: months,
      savedMonth: '2026/02',
    );

    expect(selected?.month, '2026/02');
  });

  test('falls back to the most recent month without a saved selection', () {
    expect(
      ReportPeriodSelection.resolveMonth(
        availableMonths: months,
        savedMonth: null,
      )?.month,
      '2026/03',
    );
  });

  test('falls back to the most recent month when the saved one is missing', () {
    expect(
      ReportPeriodSelection.resolveMonth(
        availableMonths: months,
        savedMonth: '2024/12',
      )?.month,
      '2026/03',
    );
  });

  test('returns null when there is no available month', () {
    expect(
      ReportPeriodSelection.resolveMonth(
        availableMonths: const [],
        savedMonth: '2026/02',
      ),
      isNull,
    );
  });

  test('restores the saved year, falling back to the first option', () {
    final years = [
      AccountabilityYearStats(year: 'Últimos 12 meses', entriesCount: 3),
      AccountabilityYearStats(year: '2026', entriesCount: 2),
      AccountabilityYearStats(year: '2025', entriesCount: 1),
    ];

    expect(
      ReportPeriodSelection.resolveYear(
        availableYears: years,
        savedYear: '2025',
      )?.year,
      '2025',
    );
    expect(
      ReportPeriodSelection.resolveYear(
        availableYears: years,
        savedYear: null,
      )?.year,
      'Últimos 12 meses',
    );
    expect(
      ReportPeriodSelection.resolveYear(
        availableYears: years,
        savedYear: '2019',
      )?.year,
      'Últimos 12 meses',
    );
    expect(
      ReportPeriodSelection.resolveYear(
        availableYears: const [],
        savedYear: '2025',
      ),
      isNull,
    );
  });
}
