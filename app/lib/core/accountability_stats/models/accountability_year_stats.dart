import 'package:flutter/material.dart';

class AccountabilityYearStats {
  final String year;
  final int entriesCount;

  final DateTimeRange? range;
  const AccountabilityYearStats({
    required this.year,
    required this.entriesCount,
    this.range,
  });
}
