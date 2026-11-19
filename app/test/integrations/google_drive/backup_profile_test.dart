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
}
