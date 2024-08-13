import 'dart:io';

import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/accountability/services/repo.dart';

class SQLiteAccountabilityImportService extends AccountabilityImportService {
  final AccountabilityRepo repo;
  SQLiteAccountabilityImportService(this.repo);

  @override
  Future import(File importedFile) async {
    var content = importedFile.readAsLinesSync();
    var lines = content.skip(1).toList();

    for (var line in lines) {
      var columns = line.split(',');
      await repo.add(AccountabilityEntryRequest(
        description: columns[1],
        value: double.parse(columns[2]),
        createdAt: DateTime.parse(columns[0]),
      ));
    }
  }
}
