import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/models/entry.dart';
import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/accountability/services/repo.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'bloc_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AccountabilityRepo>()])
void main() {
  blocTest(
    "returna uma lista vazia quando nenhum dado estiver armazenado",
    build: () {
      final AccountabilityRepo repo = MockAccountabilityRepo();
      when(repo.getEntries()).thenAnswer((_) async => []);

      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) => bloc.add(FetchAccountabilityEntries()),
    verify: (bloc) => {
      verify(bloc.repo.getEntries()).called(1),
    },
    expect: () => [
      const AccountabilityChanged(entries: [], identifications: []),
    ],
  );

  blocTest(
    "retorna uma lista contendo uma entrada armazenado",
    build: () {
      return AccountabilityBloc(repo: MockAccountabilityRepo());
    },
    act: (bloc) => bloc
      ..add(AddAccountabilityEntry(AccountabilityEntryRequest(
        description: "Descrição fictícia",
        value: 10,
        createdAt: DateTime.now(),
      ))),
    verify: (bloc) => {
      verify((bloc.repo as MockAccountabilityRepo).add(any)).called(1),
      verify(bloc.repo.getEntries()).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );

  blocTest(
    "retorna a lista atualiazada quando uma entrada é removida",
    build: () {
      return AccountabilityBloc(repo: MockAccountabilityRepo());
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
      verify((bloc.repo as MockAccountabilityRepo).delete(any)).called(1),
      verify(bloc.repo.getEntries()).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );

  blocTest(
    "retorna a lista atualizada quando uma entrada é editada",
    build: () {
      return AccountabilityBloc(repo: MockAccountabilityRepo());
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
      verify((bloc.repo as MockAccountabilityRepo).update(any)).called(1),
      verify(bloc.repo.getEntries()).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );
}
