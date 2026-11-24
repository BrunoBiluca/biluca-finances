import 'package:biluca_financas/integrations/google_drive/backup_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the fixed default profile when nothing is configured', () {
    expect(resolveBackupProfile(const {}), defaultBackupProfile);
    expect(defaultBackupProfile, 'principal');
  });

  test('uses a blank configuration as the default profile', () {
    expect(
      resolveBackupProfile(const {backupProfileEnvironmentVariable: '   '}),
      defaultBackupProfile,
    );
  });

  test('uses the configured profile name', () {
    expect(
      resolveBackupProfile(
        const {backupProfileEnvironmentVariable: ' desenvolvimento '},
      ),
      'desenvolvimento',
    );
  });

  test('finds the configured profile regardless of the name casing', () {
    expect(
      resolveBackupProfile(const {'biluca_backup_profile': 'desenvolvimento'}),
      'desenvolvimento',
    );
    expect(
      backupProfileFromEnvironment(
        const {'Biluca_Backup_Profile': ' desenvolvimento '},
      ),
      'desenvolvimento',
    );
  });

  test('reports when the profile comes from the environment', () {
    expect(backupProfileFromEnvironment(const {}), isNull);
    expect(
      backupProfileFromEnvironment(
        const {backupProfileEnvironmentVariable: '   '},
      ),
      isNull,
    );
    expect(
      backupProfileFromEnvironment(
        const {backupProfileEnvironmentVariable: 'desenvolvimento'},
      ),
      'desenvolvimento',
    );
  });
}
