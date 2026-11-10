import 'dart:io';

import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';

class FakeAccountabilityImportService extends AccountabilityImportService {
  final List<File> importedFiles = [];
  int saveCalls = 0;

  @override
  Future import(File importedFile) async {
    importedFiles.add(importedFile);
  }

  @override
  Future save() async {
    saveCalls++;
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
