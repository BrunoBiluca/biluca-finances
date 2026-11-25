import 'package:equatable/equatable.dart';

/// Criteria used to narrow accountability entries by period and value range.
class AccountabilityEntryFilter extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minValue;
  final double? maxValue;

  const AccountabilityEntryFilter({
    this.startDate,
    this.endDate,
    this.minValue,
    this.maxValue,
  });

  static const AccountabilityEntryFilter empty = AccountabilityEntryFilter();

  bool get isEmpty =>
      startDate == null &&
      endDate == null &&
      minValue == null &&
      maxValue == null;

  bool get isNotEmpty => !isEmpty;

  DateTime? get periodStart => startDate == null
      ? null
      : DateTime(startDate!.year, startDate!.month, startDate!.day);

  DateTime? get periodEnd => endDate == null
      ? null
      : DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59, 999);

  @override
  List<Object?> get props => [startDate, endDate, minValue, maxValue];
}
