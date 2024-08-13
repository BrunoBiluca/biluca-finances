import 'dart:io';

import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/services/import_service.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

class SQLiteAccountabilityImportService extends AccountabilityImportService {
  final AccountabilityRepo repo;
  SQLiteAccountabilityImportService({required this.repo});

  @override
  Future import(File importedFile) async {
    var content = importedFile.readAsLinesSync();
    var lines = content.skip(1).toList();

    var header = const CsvToListConverter().convert(content[0])[0];
    var descriptionIndex = header.indexOf("Descrição");
    var valueIndex = header.indexOf("Valor");
    var createdAtIndex = header.indexOf("Criação");
    var identificationIndex = header.indexOf("Identificação");

    var dateFormat = verifyDateFormat(lines[0]);

    var identifications = await repo.getIdentifications();

    for (var line in lines) {
      var columns = const CsvToListConverter().convert(line)[0];
      var description = columns[descriptionIndex];
      var value = columns[valueIndex];
      var createdAt = dateFormat.parse(columns[createdAtIndex]);
      var identification = columns[identificationIndex] as String;

      await repo.add(AccountabilityEntryRequest(
        description: description,
        value: value is int ? value.toDouble() : value,
        createdAt: createdAt,
        identification: identifications.firstWhereOrNull(
          (i) => i.description.toLowerCase() == identification.toLowerCase(),
        ),
      ));
    }
  }

  DateFormat verifyDateFormat(String line) {
    var createdAtStr = const CsvToListConverter().convert(line)[0][0];

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
