import 'package:biluca_financas/core/backup/models/backup_conflict.dart';
import 'package:biluca_financas/core/backup/models/backup_status.dart';

abstract class BackupService {
  Future<bool> isConfigured();

  Future<BackupStatus> getStatus();

  Future<BackupStatus> connect();

  Future<BackupStatus> revoke();

  Future<BackupStatus> syncOnOpen();

  Future<BackupStatus> syncOnClose();

  Future<BackupStatus> resolveConflict(BackupConflictResolution resolution);
}
