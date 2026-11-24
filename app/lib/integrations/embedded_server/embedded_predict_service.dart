import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:biluca_financas/common/extensions/number_extensions.dart';
import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:collection/collection.dart';
import 'package:biluca_financas/core/accountability/validators/identification_availability_rules.dart';
import 'package:biluca_financas/core/accountability_identification_prediction/service/accountability_identification_prediction_service.dart';
import 'package:biluca_financas/integrations/embedded_server/embedded_predict_server.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class EmbeddedPredictService
    implements AccountabilityIdentificationPredictionService {
  final Client http;
  final AccountabilityRepo repo;
  final Logger log = GetIt.I<LoggerManager>().instance("PredictService");
  EmbeddedPredictService(this.http, this.repo);

  @override
  Future<List<AccountabilityEntryRequest>> predict({
    List<AccountabilityEntryRequest>? entries,
    File? importedFile,
  }) async {
    try {
      Object? result;
      if (importedFile != null) {
        result = await _postFile(importedFile);
      } else if (entries != null) {
        result = await _postPredict(entries);
      } else {
        return const [];
      }

      final parsed = _parseResponse(result);
      return await _relateWithIdentificationsByName(
        parsed.headers,
        parsed.records,
      );
    } on Exception catch (e, s) {
      log.severe(
        "Prediction service unavailable or returned invalid data.",
        e,
        s,
      );
      return _fallback(entries);
    } on TypeError catch (e, s) {
      log.severe("Prediction service returned an unexpected payload.", e, s);
      return _fallback(entries);
    } on RangeError catch (e, s) {
      log.severe("Prediction service returned an incomplete record.", e, s);
      return _fallback(entries);
    }
  }

  List<AccountabilityEntryRequest> _fallback(
    List<AccountabilityEntryRequest>? entries,
  ) =>
      entries ?? const [];

  _PredictResponse _parseResponse(Object? decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException("Prediction response is not a JSON object.");
    }

    final headers = decoded["cabeçalhos"];
    final records = decoded["registros"];
    if (headers is! List || records is! List) {
      throw const FormatException(
        "Prediction response is missing cabeçalhos or registros.",
      );
    }

    return _PredictResponse(
      headers: List<String>.from(headers),
      records: records.map((record) {
        if (record is! List) {
          throw const FormatException("Prediction record is not a list.");
        }
        return record;
      }).toList(),
    );
  }

  Future<Object?> _postFile(File importedFile) async {
    var server = GetIt.I<EmbeddedPredictServer>();
    MultipartRequest request =
        MultipartRequest('POST', Uri.parse('${server.host}/predict'));
    request.files
        .add(await MultipartFile.fromPath('extrato', importedFile.path));
    var result = await request.send();

    if (result.statusCode != 200) {
      throw HttpException(result.reasonPhrase!);
    }
    return jsonDecode(await result.stream.bytesToString());
  }

  Future<Object?> _postPredict(List<AccountabilityEntryRequest> entries) async {
    var server = GetIt.I<EmbeddedPredictServer>();
    var result = await http.post(
      Uri.parse("${server.host}/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          "cabeçalhos": ["Descrição", "Valor", "Criado em"],
          "registros": entries
              .map((e) =>
                  [e.description, e.value, e.createdAt.toIso8601String()])
              .toList(),
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
    List<List<dynamic>> records,
  ) async {
    final descriptionIndex = headers.indexOf("Descrição");
    final valueIndex = headers.indexOf("Valor");
    final createdAtIndex = headers.indexOf("Criado em");
    final identificationIndex = headers.indexOf("Identificação");

    if (descriptionIndex < 0 ||
        valueIndex < 0 ||
        createdAtIndex < 0 ||
        identificationIndex < 0) {
      throw const FormatException(
        "Prediction response is missing required columns.",
      );
    }

    final requiredLength = [
      descriptionIndex,
      valueIndex,
      createdAtIndex,
      identificationIndex,
    ].reduce(math.max) + 1;

    final identifications =
        IdentificationAvailabilityRules.availableForPrediction(
      await repo.getIdentifications(),
    );

    return records.map((record) {
      if (record.length < requiredLength) {
        throw const FormatException("Prediction record is missing fields.");
      }

      return AccountabilityEntryRequest(
        createdAt: _parseDate(record[createdAtIndex] as String),
        description: record[descriptionIndex] as String,
        value: cast(record[valueIndex]),
        identification: identifications
            .where(
              (i) =>
                  i.description.toLowerCase() ==
                  record[identificationIndex].toString().toLowerCase(),
            )
            .firstOrNull,
      );
    }).toList();
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
        log.warning("Invalid date format: $date");
      }
    }
    throw FormatException("Unknown date format", date);
  }
}

class _PredictResponse {
  final List<String> headers;
  final List<List<dynamic>> records;

  _PredictResponse({
    required this.headers,
    required this.records,
  });
}
