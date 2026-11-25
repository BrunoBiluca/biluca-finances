import 'dart:async';
import 'dart:io';

import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';

class FakeAccountabilityImportService extends AccountabilityImportService {
  final List<File> importedFiles = [];
  int saveCalls = 0;
  Object? importError;
  Object? saveError;
  Completer<void>? importGate;

  @override
  Future import(File importedFile) async {
    importedFiles.add(importedFile);
    final gate = importGate;
    if (gate != null) await gate.future;
    final error = importError;
    if (error != null) throw error;
  }

  @override
  Future save() async {
    saveCalls++;
    final error = saveError;
    if (error != null) throw error;
  }

  @override
  void cancelDuplication(AccountabilityEntry entry) {
    duplicatedEntries.remove(entry);
    entries.add(AccountabilityEntryRequest(
      description: entry.description,
      value: entry.value,
      createdAt: entry.createdAt,
      identification: entry.identification,
    ));
  }
}
