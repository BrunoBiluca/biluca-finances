import 'dart:convert';
import 'dart:io';

import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:biluca_financas/common/extensions/number_extensions.dart';
import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:biluca_financas/predict/predict_local.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class PredictService {
  final Client http;
  final AccountabilityRepo repo;
  final Logger log = GetIt.I<LoggerManager>().instance("PredictService");
  PredictService(this.http, this.repo);

  Future<List<AccountabilityEntryRequest>> predict({
    List<AccountabilityEntryRequest>? entries,
    File? importedFile,
  }) async {
    try {
      dynamic result;
      if (importedFile != null) {
        result = await _postFile(importedFile);
      } else if (entries != null) {
        result = await _postPredict(entries);
      }
      return await _relateWithIdentificationsByName(
        List<String>.from(result["cabeçalhos"] as List),
        result["registros"],
      );
    } on Exception catch (e, s) {
      log.severe("Serviço de categorização indisponível.", e, s);

      if (entries != null) {
        return entries;
      }
      return [];
    }
  }

  Future<dynamic> _postFile(File importedFile) async {
    var server = GetIt.I<PredictLocal>();
    MultipartRequest request = MultipartRequest('POST', Uri.parse('${server.host}/predict'));
    request.files.add(await MultipartFile.fromPath('extrato', importedFile.path));
    var result = await request.send();

    if (result.statusCode != 200) {
      throw HttpException(result.reasonPhrase!);
    }
    return jsonDecode(await result.stream.bytesToString());
  }

  Future<dynamic> _postPredict(List<AccountabilityEntryRequest> entries) async {
    var server = GetIt.I<PredictLocal>();
    var result = await http.post(
      Uri.parse("${server.host}/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          "cabeçalhos": ["Descrição", "Valor", "Criado em"],
          "registros": entries.map((e) => [e.description, e.value, e.createdAt.toIso8601String()]).toList(),
        },
      ),
    );
    if (result.statusCode != 200) {
      throw HttpException(result.reasonPhrase!);
    }

    return jsonDecode(result.body);
  }

  Future<List<AccountabilityEntryRequest>> _relateWithIdentificationsByName(
    List<String> headers,
    List<dynamic> categorizedEntries,
  ) async {
    var descriptionIndex = headers.indexOf("Descrição");
    var valueIndex = headers.indexOf("Valor");
    var createdAtIndex = headers.indexOf("Criado em");
    var identificationIndex = headers.indexOf("Identificação");

    var identifications = await repo.getIdentifications();

    return categorizedEntries
        .map(
          (e) => AccountabilityEntryRequest(
            createdAt: _parseDate(e[createdAtIndex]),
            description: e[descriptionIndex],
            value: cast(e[valueIndex]),
            identification: identifications.firstWhere(
              (i) => i.description.toLowerCase() == e[identificationIndex].toLowerCase(),
            ),
          ),
        )
        .toList();
  }

  DateTime _parseDate(String date) {
    var formats = [
      "dd/MM/yyyy",
      "yyyy-MM-ddTHH:mm:ss",
    ];
    for (var format in formats) {
      try {
        return DateFormat(format).parse(date);
      } on FormatException {
        log.warning("Formato de data inválido: $date");
      }
    }
    throw FormatException("Formato de data desconhecido", date);
  }
}
