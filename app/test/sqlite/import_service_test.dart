import 'dart:io';

import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/predict/predict_service.dart';
import 'package:biluca_financas/sqlite/accountability/import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../_helpers/mocktail_extensions.dart';
import '../accountability/mocks/fake_accountability_entry.dart';
import '../accountability/mocks/fake_accountability_entry_request.dart';
import '../accountability/mocks/mock_accountability_repo.dart';

class MockPredictService extends Mock implements PredictService {}

void main() {
  test("deve returnar uma lista vazia se não existir um servidor de predição", () async {
    var service = SQLiteAccountabilityImportService(
      repo: MockAccountabilityRepo(),
      predictService: null,
    );

    service.import(File(""));
    expect(service.entries, isEmpty);
  });

  test("deve retornar todas as entradas preditas quando não existem nenhuma entrada persistida", () async {
    var predictService = MockPredictService();
    when(
      () => predictService.predict(importedFile: any(named: "importedFile")),
    ).thenAnswer(
      (_) async => [
        FakeAccountabilityEntryRequest(),
        FakeAccountabilityEntryRequest(),
      ],
    );

    registerFallbackValue(FakeAccountabilityEntryRequest());
    var repo = MockAccountabilityRepo();
    when(() => repo.exists(any(that: isA<AccountabilityEntryRequest>()))).thenAnswer((_) async => null);
    var service = SQLiteAccountabilityImportService(
      repo: repo,
      predictService: predictService,
    );

    await service.import(File(""));
    expect(service.entries, hasLength(2));
  });

  test("deve separar as entradas duplicadas de as que não são duplicadas", () async {
    var predictService = MockPredictService();
    when(
      () => predictService.predict(importedFile: any(named: "importedFile")),
    ).thenAnswer(
      (_) async => [
        FakeAccountabilityEntryRequest(),
        FakeAccountabilityEntryRequest(),
      ],
    );

    registerFallbackValue(FakeAccountabilityEntryRequest());
    var repo = MockAccountabilityRepo();
    when(() => repo.exists(any(that: isA<AccountabilityEntryRequest>()))).thenAnswerMany([
      (_) async => null,
      (_) async => FakeAccountabilityEntry(),
    ]);
    var service = SQLiteAccountabilityImportService(
      repo: repo,
      predictService: predictService,
    );

    await service.import(File(""));
    expect(service.entries, hasLength(1));
    expect(service.duplicatedEntries, hasLength(1));
  });
}
