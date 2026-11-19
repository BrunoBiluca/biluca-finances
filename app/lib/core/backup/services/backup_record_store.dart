import 'package:biluca_financas/core/backup/models/backup_record.dart';

abstract class BackupRecordStore {
  Future<BackupRecord?> read();

  Future<void> write(BackupRecord record);

  Future<void> clear();
}
