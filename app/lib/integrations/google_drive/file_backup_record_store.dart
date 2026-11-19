import 'dart:convert';
import 'dart:io';

import 'package:biluca_financas/core/backup/models/backup_record.dart';
import 'package:biluca_financas/core/backup/services/backup_record_store.dart';

class FileBackupRecordStore implements BackupRecordStore {
  final File file;

  const FileBackupRecordStore(this.file);

  @override
  Future<BackupRecord?> read() async {
    if (!await file.exists()) return null;

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return BackupRecord.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(BackupRecord record) async {
    final parent = file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }
    await file.writeAsString(jsonEncode(record.toJson()), flush: true);
  }

  @override
  Future<void> clear() async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
