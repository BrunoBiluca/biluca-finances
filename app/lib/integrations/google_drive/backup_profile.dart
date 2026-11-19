import 'dart:io';

const String defaultBackupProfile = 'principal';
const String backupProfileEnvironmentVariable = 'BILUCA_BACKUP_PROFILE';

String resolveBackupProfile([Map<String, String>? environment]) {
  final value =
      (environment ?? Platform.environment)[backupProfileEnvironmentVariable];
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return defaultBackupProfile;
  return trimmed;
}
