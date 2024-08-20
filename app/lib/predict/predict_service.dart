import 'dart:convert';

import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:biluca_financas/common/number_extensions.dart';
import 'package:http/http.dart';

class PredictService {
  final Client http;
  final AccountabilityRepo repo;
  PredictService(this.http, this.repo);

  Future<List<AccountabilityEntryRequest>> predict(List<AccountabilityEntryRequest> entries) async {
    var result = await http.post(
      Uri.parse("http://localhost:5000/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          "cabeçalhos": ["Descrição", "Valor", "Criado em"],
          "registros": entries.map((e) => [e.description, e.value, e.createdAt.toIso8601String()]).toList(),
        },
      ),
    );

    if (result.statusCode != 200) {
      throw Exception(result.reasonPhrase);
    }

    var entriesCategorized = jsonDecode(result.body)["registros"] as List<dynamic>;

    var identifications = await repo.getIdentifications();

    return entriesCategorized
        .map(
          (e) => AccountabilityEntryRequest(
            description: e[0],
            value: cast(e[1]),
            createdAt: DateTime.parse(e[2]),
            identification: identifications.firstWhere((i) => i.description.toLowerCase() == e[3].toLowerCase()),
          ),
        )
        .toList();
  }
}
