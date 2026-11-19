import 'package:biluca_financas/core/backup/models/backup_status.dart';
import 'package:biluca_financas/core/backup/services/backup_service.dart';

Future<BackupStatus?> runStartupBackupSync(BackupService service) async {
  try {
    if (!await service.isConfigured()) return null;
    return await service.syncOnOpen();
  } catch (_) {
    return null;
  }
}
