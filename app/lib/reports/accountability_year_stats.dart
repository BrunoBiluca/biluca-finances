class AccountabilityYearStats {
  final String year;
  final int entriesCount;
  AccountabilityYearStats(this.year, this.entriesCount);

  factory AccountabilityYearStats.fromMap(Map<String, dynamic> map) {
    return AccountabilityYearStats(
      map['year'],
      map['entriesCount'],
    );
  }
}
