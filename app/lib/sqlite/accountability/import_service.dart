import 'dart:io';

import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:biluca_financas/common/number_extensions.dart';
import 'package:biluca_financas/predict/predict_service.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

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

  List<AccountabilityEntryRequest> _convertCsv(File importedFile) {
    var content = importedFile.readAsLinesSync();

    var lines = content.skip(1).toList();

    var header = const CsvToListConverter().convert(content[0])[0];
    var descriptionIndex = header.indexOf("Descrição");
    var valueIndex = header.indexOf("Valor");
    var createdAtIndex = header.indexOf("Criação");

    var dateFormat = verifyDateFormat(lines[0], createdAtIndex);

    List<AccountabilityEntryRequest> entries = [];
    for (var line in lines) {
      var columns = const CsvToListConverter().convert(line)[0];
      var description = columns[descriptionIndex];
      var value = cast(columns[valueIndex]);
      var createdAt = dateFormat.parse(columns[createdAtIndex]);

      entries.add(AccountabilityEntryRequest(
        description: description,
        value: value is int ? value.toDouble() : value,
        createdAt: createdAt,
      ));
    }
    return entries;
  }


  DateFormat verifyDateFormat(String line, int dateIndex) {
    var csvLine = const CsvToListConverter().convert(line)[0];
    var createdAtStr = csvLine[dateIndex];

    var availablesFormats = ['dd/MM/yyyy', 'yyyy-MM-dd', "MMMM d, yyyy"];

    for (var format in availablesFormats) {
      try {
        var _ = DateFormat(format).parse(createdAtStr);
        return DateFormat(format);
      } catch (e) {
        continue;
      }
    }

    throw Exception('Formato de data inválido');
  }
}
