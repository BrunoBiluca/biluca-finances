import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/backup/services/startup_backup_sync.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_mocks/fake_backup_service.dart';

void main() {
  test('does not synchronize when the backup is not configured', () async {
    final service = FakeBackupService(
      BackupStatus.notConfigured(databaseVersion: 10),
    );

    final result = await runStartupBackupSync(service);

    expect(result, isNull);
    expect(service.syncOnOpenCalls, 0);
  });

  test('synchronizes on open when the backup is configured', () async {
    final synchronized = BackupStatus(
      state: BackupSyncState.synchronized,
      isConfigured: true,
      databaseVersion: 10,
      lastSyncAt: DateTime.utc(2026, 5, 6),
    );
    final service = FakeBackupService(synchronized);

    final result = await runStartupBackupSync(service);

    expect(service.syncOnOpenCalls, 1);
    expect(result, synchronized);
  });

  test('keeps the application starting when the synchronization fails', () async {
    final service = FakeBackupService(
      BackupStatus(
        state: BackupSyncState.configured,
        isConfigured: true,
        databaseVersion: 10,
      ),
    )..syncError = Exception('sem rede');

    expect(await runStartupBackupSync(service), isNull);
  });
}
