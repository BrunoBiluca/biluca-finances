class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => message;
}
