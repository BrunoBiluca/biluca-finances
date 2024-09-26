import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/models/entry.dart';
import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks/fake_accountability_entry.dart';
import 'mocks/fake_accountability_entry_request.dart';
import 'mocks/mock_accountability_repo.dart';

void main() {
  blocTest(
    "returna uma lista vazia quando nenhum dado estiver armazenado",
    build: () {
      final AccountabilityRepo repo = MockAccountabilityRepo();
      when(() => repo.getEntries(limit: any(named: "limit"), offset: any(named: "offset"))).thenAnswer((_) async => []);
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);

      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) => bloc.add(FetchAccountabilityEntries()),
    verify: (bloc) => {
      verify(() => bloc.repo.getEntries(limit: any(named: "limit"), offset: any(named: "offset"))).called(1),
    },
    expect: () => [
      const AccountabilityChanged(entries: [], identifications: []),
    ],
  );

  blocTest(
    "retorna uma lista contendo uma entrada armazenado",
    build: () {
      registerFallbackValue(FakeAccountabilityEntryRequest());
      final AccountabilityRepo repo = MockAccountabilityRepo();
      when(() => repo.add(any(that: isA<AccountabilityEntryRequest>())))
          .thenAnswer((_) async => FakeAccountabilityEntry());
      when(() => repo.getEntries(limit: any(named: "limit"), offset: any(named: "offset"))).thenAnswer((_) async => []);
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);
      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) => bloc
      ..add(AddAccountabilityEntry(AccountabilityEntryRequest(
        description: "Descrição fictícia",
        value: 10,
        createdAt: DateTime.now(),
      ))),
    verify: (bloc) => {
      verify(() => (bloc.repo as MockAccountabilityRepo).add(any())).called(1),
      verify(() => bloc.repo.getEntries(limit: any(named: "limit"), offset: any(named: "offset"))).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );

  blocTest(
    "retorna a lista atualiazada quando uma entrada é removida",
    build: () {
      registerFallbackValue(FakeAccountabilityEntry());

      var repo = MockAccountabilityRepo();
      when(() => repo.delete(any(that: isA<AccountabilityEntry>()))).thenAnswer((_) async => {});
      when(() => repo.getEntries(limit: any(named: "limit"), offset: any(named: "offset"))).thenAnswer((_) async => []);
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);
      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) => bloc
      ..add(DeleteAccountabilityEntry(AccountabilityEntry(
        id: 0,
        description: "",
        value: 0,
        createdAt: DateTime.now(),
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ))),
    verify: (bloc) => {
      verify(() => (bloc.repo as MockAccountabilityRepo).delete(any())).called(1),
      verify(() => bloc.repo.getEntries(limit: any(named: "limit"), offset: any(named: "offset"))).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );

  blocTest(
    "retorna a lista atualizada quando uma entrada é editada",
    build: () {
      registerFallbackValue(FakeAccountabilityEntry());
      var repo = MockAccountabilityRepo();
      when(() => repo.update(any(that: isA<AccountabilityEntry>()))).thenAnswer((_) async => FakeAccountabilityEntry());
      when(() => repo.getEntries(limit: any(named: "limit"), offset: any(named: "offset"))).thenAnswer((_) async => []);
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);
      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) => bloc
      ..add(UpdateAccountabilityEntry(AccountabilityEntry(
        id: 0,
        description: "",
        value: 0,
        createdAt: DateTime.now(),
        insertedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ))),
    verify: (bloc) => {
      verify(() => (bloc.repo as MockAccountabilityRepo).update(any())).called(1),
      verify(() => bloc.repo.getEntries(limit: any(named: "limit"), offset: any(named: "offset"))).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );
}
