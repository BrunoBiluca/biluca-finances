import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/bloc/states.dart';
import 'package:biluca_financas/accountability/models/entry_request.dart';
import 'package:biluca_financas/sqlite/sqlite_accountability_repo.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'bloc_test.mocks.dart';

@GenerateNiceMocks([MockSpec<SQLiteAccountabilityRepo>()])
void main() {
  blocTest(
    "returna uma lista vazia quando nenhum dado estiver armazenado",
    build: () {
      final SQLiteAccountabilityRepo repo = MockSQLiteAccountabilityRepo();
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
      return AccountabilityBloc(repo: MockSQLiteAccountabilityRepo());
    },
    act: (bloc) => bloc..add(AddAccountabilityEntry()),
    verify: (bloc) => {
      verify((bloc.repo as MockSQLiteAccountabilityRepo).add(any)).called(1),
      verify(bloc.repo.getEntries()).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );
}
