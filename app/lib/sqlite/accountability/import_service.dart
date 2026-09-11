import 'dart:io';

import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/services/accountability_import_service.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:biluca_financas/predict/predict_service.dart';

class SQLiteAccountabilityImportService extends AccountabilityImportService {
  final AccountabilityRepo repo;
  final PredictService? predictService;
  SQLiteAccountabilityImportService({required this.repo, this.predictService});

  @override
  Future import(File importedFile) async {
    if (predictService != null) {
      var predictedEntries = await predictService!.predict(importedFile: importedFile);

      for (var i = 0; i < predictedEntries.length; i++) {
        var entry = predictedEntries[i];
        var result = await repo.exists(entry);

        if (result != null) {
          duplicatedEntries.add(result);
        } else {
          entries.add(entry);
        }
      }
    }
  }

  @override
  Future save() async {
    for (var entry in entries) {
      await repo.add(entry);
    }
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
