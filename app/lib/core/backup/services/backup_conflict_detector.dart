import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:biluca_financas/core/backup/models/remote_backup_file.dart';
import 'package:biluca_financas/core/backup/models/sync_metadata.dart';
import 'package:equatable/equatable.dart';

enum BackupSyncAction { none, uploadLocal, downloadRemote, conflict }

class BackupSyncPlan extends Equatable {
  final BackupSyncAction action;
  final BackupConflict? conflict;

  const BackupSyncPlan({required this.action, this.conflict});

  @override
  List<Object?> get props => [action, conflict];
}

const Duration _remoteModificationTolerance = Duration(seconds: 1);

BackupSyncPlan planBackupSync({
  required SyncMetadata? metadata,
  required String localHash,
  required RemoteBackupFile? remoteFile,
  required DateTime localModifiedAt,
}) {
  if (remoteFile == null) {
    return const BackupSyncPlan(action: BackupSyncAction.uploadLocal);
  }

  final localChanged = metadata == null || metadata.localHash != localHash;
  final remoteChanged = metadata == null ||
      !_sameInstant(metadata.remoteModifiedAt, remoteFile.modifiedAt);

  if (localChanged && remoteChanged) {
    return BackupSyncPlan(
      action: BackupSyncAction.conflict,
      conflict: BackupConflict(
        localModifiedAt: localModifiedAt,
        remoteModifiedAt: remoteFile.modifiedAt ?? localModifiedAt,
      ),
    );
  }
  if (remoteChanged) {
    return const BackupSyncPlan(action: BackupSyncAction.downloadRemote);
  }
  if (localChanged) {
    return const BackupSyncPlan(action: BackupSyncAction.uploadLocal);
  }
  return const BackupSyncPlan(action: BackupSyncAction.none);
}

BackupConflict? detectBackupConflict({
  required SyncMetadata? metadata,
  required String localHash,
  required RemoteBackupFile? remoteFile,
  required DateTime localModifiedAt,
}) {
  return planBackupSync(
    metadata: metadata,
    localHash: localHash,
    remoteFile: remoteFile,
    localModifiedAt: localModifiedAt,
  ).conflict;
}

bool _sameInstant(DateTime expected, DateTime? actual) {
  if (actual == null) return false;
  return expected.toUtc().difference(actual.toUtc()).abs() <
      _remoteModificationTolerance;
}
