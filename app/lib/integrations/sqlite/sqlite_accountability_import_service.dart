import 'dart:io';

import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability_identification_prediction/service/accountability_identification_prediction_service.dart';
import 'package:biluca_financas/core/accountability_import/services/accountability_import_service.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';

class SQLiteAccountabilityImportService extends AccountabilityImportService {
  final AccountabilityRepo repo;
  final AccountabilityIdentificationPredictionService? predictService;
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
    await repo.addAll(List.of(entries));
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
