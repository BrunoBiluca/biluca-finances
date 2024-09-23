import 'dart:convert';

import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:biluca_financas/predict/predict_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import '../accountability/mocks/mock_accountability_repo.dart';

void main() {
  test("deve retornar a mesma lista passada quando o serviço estiver indisponível", () async {
    var client = MockClient((req) async {
      return Response("", 500, reasonPhrase: "ERROR");
    });
    var repo = MockAccountabilityRepo();

    var service = PredictService(client, repo);
    var entries = await service.predict(entries: []);

    expect(entries, isEmpty);
  });

  test("deve retornar os dados com o campo de identificação preenchido", () async {
    var client = MockClient((req) async {
      var expectedPath = req.url.pathSegments.last == "predict";

      var data = jsonDecode(req.body);
      var expectedBody = data["cabeçalhos"] != null && data["registros"] != null;

      if (!expectedPath) {
        return Response("", 404, reasonPhrase: "Not found");
      }

      if (!expectedBody) {
        return Response("", 400, reasonPhrase: "Bad request");
      }

      return Response(
        jsonEncode({
          "cabeçalhos": [...data["cabeçalhos"], "Identificação"],
          "registros": data["registros"].map((r) => [...r, "supermercado"]).toList()
        }),
        200,
      );
    });

    var expectedIdentification = AccountabilityIdentification("supermercado", Colors.black);
    var repo = MockAccountabilityRepo();
    when(() => repo.getIdentifications()).thenAnswer(
      (_) async => Future.delayed(const Duration(milliseconds: 10), () => [expectedIdentification]),
    );

    final service = PredictService(client, repo);

    var result = await service.predict(entries: [
      AccountabilityEntryRequest(description: "Descricão fictício", value: 10, createdAt: DateTime.now()),
      AccountabilityEntryRequest(description: "Descricão fictício", value: 20, createdAt: DateTime.now()),
      AccountabilityEntryRequest(description: "Descricão fictício", value: 30, createdAt: DateTime.now()),
    ]);

    expect(result.length, 3);
    expect(result[0].identification, isNotNull);
    expect(result[1].identification, isNotNull);
    expect(result[2].identification, isNotNull);
  });
}
