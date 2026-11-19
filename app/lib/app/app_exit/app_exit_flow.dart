import 'package:biluca_financas/core/backup/services/backup_service.dart';

Future<bool> runApplicationExitFlow({
  required BackupService service,
  required Future<bool> Function() showSynchronizationModal,
}) async {
  try {
    if (!await service.isConfigured()) return true;
  } catch (_) {
    return true;
  }
  return showSynchronizationModal();
}
