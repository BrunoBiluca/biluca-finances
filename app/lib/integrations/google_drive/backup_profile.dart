import 'dart:io';

const String defaultBackupProfile = 'principal';
const String backupProfileEnvironmentVariable = 'BILUCA_BACKUP_PROFILE';

/// Profile defined by the environment, or `null` when there is no usable value.
///
/// Windows environment variable names are case-insensitive, but
/// `Platform.environment` is case-sensitive, so the lookup ignores the name's
/// case.
String? backupProfileFromEnvironment([Map<String, String>? environment]) {
  final env = environment ?? Platform.environment;
  for (final entry in env.entries) {
    if (entry.key.toUpperCase() != backupProfileEnvironmentVariable) continue;
    final trimmed = entry.value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return null;
}

String resolveBackupProfile([Map<String, String>? environment]) {
  return backupProfileFromEnvironment(environment) ?? defaultBackupProfile;
}
