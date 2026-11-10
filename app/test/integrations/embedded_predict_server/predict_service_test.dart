import 'dart:convert';

import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/common/logging/logger_manager.dart';
import 'package:biluca_financas/integrations/embedded_server/embedded_predict_server.dart';
import 'package:biluca_financas/integrations/embedded_server/embedded_predict_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import '../../_mocks/mock_accountability_repo.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<LoggerManager>(LoggerManager());
    GetIt.I.registerSingleton<EmbeddedPredictServer>(EmbeddedPredictServer());
  });

  test(
      "deve retornar a mesma lista passada quando o serviço estiver indisponível",
      () async {
    var client = MockClient((req) async {
      return Response("", 500, reasonPhrase: "ERROR");
    });
    var repo = MockAccountabilityRepo();

    var service = EmbeddedPredictService(client, repo);
    var entries = await service.predict(entries: []);

    expect(entries, isEmpty);
  });

  test("deve retornar os dados com o campo de identificação preenchido",
      () async {
    var client = MockClient((req) async {
      var expectedPath = req.url.pathSegments.last == "predict";

      var data = jsonDecode(req.body);
      var expectedBody =
          data["cabeçalhos"] != null && data["registros"] != null;

      if (!expectedPath) {
        return Response("", 404, reasonPhrase: "Not found");
      }

      if (!expectedBody) {
        return Response("", 400, reasonPhrase: "Bad request");
      }

      return Response(
        jsonEncode({
          "cabeçalhos": [...data["cabeçalhos"], "Identificação"],
          "registros":
              data["registros"].map((r) => [...r, "supermercado"]).toList()
        }),
        200,
      );
    });

    var expectedIdentification =
        AccountabilityIdentification("supermercado", Colors.black);
    var repo = MockAccountabilityRepo();
    when(() => repo.getIdentifications()).thenAnswer(
      (_) async => Future.delayed(
          const Duration(milliseconds: 10), () => [expectedIdentification]),
    );

    final service = EmbeddedPredictService(client, repo);

    var result = await service.predict(entries: [
      AccountabilityEntryRequest(
          description: "Descricão fictício",
          value: 10,
          createdAt: DateTime.now()),
      AccountabilityEntryRequest(
          description: "Descricão fictício",
          value: 20,
          createdAt: DateTime.now()),
      AccountabilityEntryRequest(
          description: "Descricão fictício",
          value: 30,
          createdAt: DateTime.now()),
    ]);

    expect(result.length, 3);
    expect(result[0].identification, isNotNull);
    expect(result[1].identification, isNotNull);
    expect(result[2].identification, isNotNull);
  });

  MockClient predictClient() {
    return MockClient((req) async {
      final data = jsonDecode(req.body);
      return Response(
        jsonEncode({
          "cabeçalhos": [...data["cabeçalhos"], "Identificação"],
          "registros":
              data["registros"].map((r) => [...r, "supermercado"]).toList()
        }),
        200,
      );
    });
  }

  test("deve ignorar identificações descontinuadas na categorização", () async {
    final active = AccountabilityIdentification("supermercado", Colors.green);
    final discontinued = AccountabilityIdentification(
      "supermercado",
      Colors.grey,
      discontinued: true,
    );
    final repo = MockAccountabilityRepo();
    when(() => repo.getIdentifications()).thenAnswer(
      (_) async => [discontinued, active],
    );

    final service = EmbeddedPredictService(predictClient(), repo);
    final result = await service.predict(entries: [
      AccountabilityEntryRequest(
        description: "Descrição",
        value: 10,
        createdAt: DateTime.now(),
      ),
    ]);

    expect(result.single.identification, same(active));
  });

  test(
      "deve manter a entrada sem identificação quando só houver categoria descontinuada",
      () async {
    final discontinued = AccountabilityIdentification(
      "supermercado",
      Colors.grey,
      discontinued: true,
    );
    final repo = MockAccountabilityRepo();
    when(() => repo.getIdentifications()).thenAnswer(
      (_) async => [discontinued],
    );

    final service = EmbeddedPredictService(predictClient(), repo);
    final result = await service.predict(entries: [
      AccountabilityEntryRequest(
        description: "Descrição",
        value: 10,
        createdAt: DateTime.now(),
      ),
    ]);

    expect(result.single.identification, isNull);
  });
}
