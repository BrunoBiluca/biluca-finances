import 'package:biluca_financas/core/backup/models/remote_backup_file.dart';
import 'package:biluca_financas/core/backup/models/sync_metadata.dart';
import 'package:biluca_financas/core/backup/services/backup_conflict_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final remoteModifiedAt = DateTime.utc(2026, 5, 6, 10);
  final localModifiedAt = DateTime.utc(2026, 5, 6, 11);
  final metadata = SyncMetadata(
    localHash: 'local-hash',
    remoteFileId: 'remote-id',
    remoteModifiedAt: remoteModifiedAt,
    lastSyncedAt: DateTime.utc(2026, 5, 6, 10, 5),
  );
  final remoteFile = RemoteBackupFile(
    id: 'remote-id',
    modifiedAt: remoteModifiedAt,
  );

  group('planBackupSync', () {
    test('uploads the local file on the initial synchronization', () {
      final plan = planBackupSync(
        metadata: null,
        localHash: 'local-hash',
        remoteFile: null,
        localModifiedAt: localModifiedAt,
      );

      expect(plan.action, BackupSyncAction.uploadLocal);
      expect(plan.conflict, isNull);
    });

    test('keeps both files untouched when nothing changed', () {
      final plan = planBackupSync(
        metadata: metadata,
        localHash: 'local-hash',
        remoteFile: remoteFile,
        localModifiedAt: localModifiedAt,
      );

      expect(plan.action, BackupSyncAction.none);
      expect(plan.conflict, isNull);
    });

    test('uploads the local file when only the local file changed', () {
      final plan = planBackupSync(
        metadata: metadata,
        localHash: 'another-hash',
        remoteFile: remoteFile,
        localModifiedAt: localModifiedAt,
      );

      expect(plan.action, BackupSyncAction.uploadLocal);
      expect(plan.conflict, isNull);
    });

    test('downloads the remote file when only the remote file changed', () {
      final plan = planBackupSync(
        metadata: metadata,
        localHash: 'local-hash',
        remoteFile: RemoteBackupFile(
          id: 'remote-id',
          modifiedAt: DateTime.utc(2026, 5, 6, 12),
        ),
        localModifiedAt: localModifiedAt,
      );

      expect(plan.action, BackupSyncAction.downloadRemote);
      expect(plan.conflict, isNull);
    });

    test('reports a conflict when both files changed', () {
      final plan = planBackupSync(
        metadata: metadata,
        localHash: 'another-hash',
        remoteFile: RemoteBackupFile(
          id: 'remote-id',
          modifiedAt: DateTime.utc(2026, 5, 6, 12),
        ),
        localModifiedAt: localModifiedAt,
      );

      expect(plan.action, BackupSyncAction.conflict);
      expect(plan.conflict, isNotNull);
      expect(plan.conflict!.localModifiedAt, localModifiedAt);
      expect(plan.conflict!.remoteModifiedAt, DateTime.utc(2026, 5, 6, 12));
    });

    test('reports a conflict when a remote backup exists without a local baseline', () {
      final plan = planBackupSync(
        metadata: null,
        localHash: 'local-hash',
        remoteFile: remoteFile,
        localModifiedAt: localModifiedAt,
      );

      expect(plan.action, BackupSyncAction.conflict);
      expect(plan.conflict, isNotNull);
    });

    test('ignores sub-second differences in the remote modification time', () {
      final plan = planBackupSync(
        metadata: SyncMetadata(
          localHash: 'local-hash',
          remoteFileId: 'remote-id',
          remoteModifiedAt: DateTime.utc(2026, 5, 6, 10, 0, 0, 400),
          lastSyncedAt: DateTime.utc(2026, 5, 6, 10, 5),
        ),
        localHash: 'another-hash',
        remoteFile: RemoteBackupFile(
          id: 'remote-id',
          modifiedAt: DateTime.utc(2026, 5, 6, 10),
        ),
        localModifiedAt: localModifiedAt,
      );

      expect(plan.action, BackupSyncAction.uploadLocal);
    });
  });

  group('detectBackupConflict', () {
    test('returns the conflict detected by the plan', () {
      final conflict = detectBackupConflict(
        metadata: metadata,
        localHash: 'another-hash',
        remoteFile: RemoteBackupFile(
          id: 'remote-id',
          modifiedAt: DateTime.utc(2026, 5, 6, 12),
        ),
        localModifiedAt: localModifiedAt,
      );

      expect(conflict, isNotNull);
      expect(conflict!.remoteModifiedAt, DateTime.utc(2026, 5, 6, 12));
    });

    test('returns null when there is no conflict', () {
      final conflict = detectBackupConflict(
        metadata: metadata,
        localHash: 'local-hash',
        remoteFile: remoteFile,
        localModifiedAt: localModifiedAt,
      );

      expect(conflict, isNull);
    });
  });
}
