class AccountabilityMonthStats {
  final String month;
  final int entriesCount;
  AccountabilityMonthStats(this.month, this.entriesCount);

  factory AccountabilityMonthStats.fromMap(Map<String, dynamic> map) {
    return AccountabilityMonthStats(
      map['month'],
      map['entriesCount'],
    );
  }
}
