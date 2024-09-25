import 'dart:io';

import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:biluca_financas/predict/predict_service.dart';

class SQLiteAccountabilityImportService extends AccountabilityImportService {
  final AccountabilityRepo repo;
  final PredictService? predictService;
  SQLiteAccountabilityImportService({required this.repo, this.predictService});

  @override
  Future import(File importedFile) async {
    if (predictService != null) {
      entries = await predictService!.predict(importedFile: importedFile);
    }
  }

  @override
  Future save() async {
    for (var entry in entries) {
      await repo.add(entry);
    }
  }
}
