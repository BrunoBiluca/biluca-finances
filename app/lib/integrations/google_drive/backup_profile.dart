import 'dart:io';

const String defaultBackupProfile = 'principal';
const String backupProfileEnvironmentVariable = 'BILUCA_BACKUP_PROFILE';

/// Perfil definido pelo ambiente, ou `null` quando não há valor utilizável.
///
/// Os nomes de variáveis de ambiente no Windows não diferenciam maiúsculas de
/// minúsculas, mas `Platform.environment` diferencia, então a busca ignora a
/// caixa do nome.
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
