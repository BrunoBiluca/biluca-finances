import 'dart:async';

import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry.dart';
import 'package:biluca_financas/core/accountability/models/accountability_entry_request.dart';
import 'package:biluca_financas/core/accountability/services/accountability_repo.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../_mocks/fake_accountability_entry.dart';
import '../../_mocks/fake_accountability_entry_request.dart';
import '../../_mocks/mock_accountability_repo.dart';

void main() {
  late Completer<List<AccountabilityEntry>> outdatedRequest;
  late AccountabilityEntry oldEntry;

  blocTest(
    "returna uma lista vazia quando nenhum dado estiver armazenado",
    build: () {
      final AccountabilityRepo repo = MockAccountabilityRepo();
      when(() => repo.getEntries(
          limit: any(named: "limit"),
          offset: any(named: "offset"))).thenAnswer((_) async => []);
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);

      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) => bloc.add(FetchAccountabilityEntries()),
    verify: (bloc) => {
      verify(() => bloc.repo.getEntries(
          limit: any(named: "limit"), offset: any(named: "offset"))).called(1),
    },
    expect: () => [
      const AccountabilityChanged(entries: [], identifications: []),
    ],
  );

  blocTest(
    "keeps search and identification filters in the loaded state",
    build: () {
      final AccountabilityRepo repo = MockAccountabilityRepo();
      final entries = List<AccountabilityEntry>.generate(
        AccountabilityBloc.pageSize + 1,
        (index) => AccountabilityEntry(
          id: index,
          description: "Entry $index",
          value: index.toDouble(),
          createdAt: DateTime(2026).add(Duration(seconds: index)),
          insertedAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      );
      when(
        () => repo.searchEntries(
          searchQuery: any(named: "searchQuery"),
          identificationId: any(named: "identificationId"),
          limit: any(named: "limit"),
          offset: any(named: "offset"),
        ),
      ).thenAnswer((_) async => entries);
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);

      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) => bloc.add(
      const SearchAccountabilityEntries(
          query: "market", identificationId: "groceries"),
    ),
    verify: (bloc) {
      verify(
        () => bloc.repo.searchEntries(
          searchQuery: "market",
          identificationId: "groceries",
          limit: AccountabilityBloc.pageSize + 1,
          offset: 0,
        ),
      ).called(1);
    },
    expect: () => [
      isA<AccountabilityChanged>()
          .having((state) => state.searchQuery, "searchQuery", "market")
          .having((state) => state.identificationId, "identificationId",
              "groceries")
          .having((state) => state.isLoading, "isLoading", true),
      isA<AccountabilityChanged>()
          .having((state) => state.searchQuery, "searchQuery", "market")
          .having((state) => state.identificationId, "identificationId",
              "groceries")
          .having((state) => state.isLoading, "isLoading", false)
          .having((state) => state.entries.length, "entries.length",
              AccountabilityBloc.pageSize)
          .having((state) => state.hasMore, "hasMore", true),
    ],
  );

  blocTest(
    "ignores results from an outdated search when the filters change",
    setUp: () {
      outdatedRequest = Completer<List<AccountabilityEntry>>();
      oldEntry = _entry(1, "Old result");
    },
    build: () {
      final repo = MockAccountabilityRepo();
      final newEntry = _entry(2, "New result");
      when(
        () => repo.searchEntries(
          searchQuery: "old",
          identificationId: null,
          limit: AccountabilityBloc.pageSize + 1,
          offset: 0,
        ),
      ).thenAnswer((_) => outdatedRequest.future);
      when(
        () => repo.searchEntries(
          searchQuery: "new",
          identificationId: "food",
          limit: AccountabilityBloc.pageSize + 1,
          offset: 0,
        ),
      ).thenAnswer((_) async => [newEntry]);
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);

      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) async {
      bloc.add(const SearchAccountabilityEntries(
          query: "old", identificationId: null));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SearchAccountabilityEntries(
          query: "new", identificationId: "food"));
      await Future<void>.delayed(Duration.zero);
      outdatedRequest.complete([oldEntry]);
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      isA<AccountabilityChanged>()
          .having((state) => state.searchQuery, "searchQuery", "old")
          .having(
            (state) => state.isLoading,
            "isLoading",
            true,
          ),
      isA<AccountabilityChanged>()
          .having((state) => state.searchQuery, "searchQuery", "new")
          .having(
            (state) => state.isLoading,
            "isLoading",
            true,
          ),
      isA<AccountabilityChanged>()
          .having((state) => state.searchQuery, "searchQuery", "new")
          .having((state) => state.identificationId, "identificationId", "food")
          .having((state) => state.entries.single.description,
              "entry description", "New result"),
    ],
  );

  blocTest(
    "loads the next filtered page using the active criteria",
    build: () {
      final repo = MockAccountabilityRepo();
      final firstPage = List<AccountabilityEntry>.generate(
        AccountabilityBloc.pageSize + 1,
        (index) => _entry(index, "Food $index"),
      );
      final nextEntry = _entry(200, "Food next");
      when(
        () => repo.searchEntries(
          searchQuery: "food",
          identificationId: "food",
          limit: AccountabilityBloc.pageSize + 1,
          offset: 0,
        ),
      ).thenAnswer((_) async => firstPage);
      when(
        () => repo.searchEntries(
          searchQuery: "food",
          identificationId: "food",
          limit: AccountabilityBloc.pageSize + 1,
          offset: AccountabilityBloc.pageSize,
        ),
      ).thenAnswer((_) async => [nextEntry]);
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);

      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) async {
      bloc.add(const SearchAccountabilityEntries(
          query: "food", identificationId: "food"));
      await Future<void>.delayed(Duration.zero);
      bloc.add(LoadMoreAccountabilityEntries());
    },
    verify: (bloc) {
      verify(
        () => bloc.repo.searchEntries(
          searchQuery: "food",
          identificationId: "food",
          limit: AccountabilityBloc.pageSize + 1,
          offset: AccountabilityBloc.pageSize,
        ),
      ).called(1);
    },
    expect: () => [
      isA<AccountabilityChanged>()
          .having((state) => state.isLoading, "isLoading", true),
      isA<AccountabilityChanged>()
          .having((state) => state.entries.length, "entries.length",
              AccountabilityBloc.pageSize)
          .having((state) => state.hasMore, "hasMore", true),
      isA<AccountabilityChanged>()
          .having((state) => state.isLoading, "isLoading", true),
      isA<AccountabilityChanged>()
          .having((state) => state.entries.length, "entries.length",
              AccountabilityBloc.pageSize + 1)
          .having((state) => state.hasMore, "hasMore", false),
    ],
  );

  blocTest(
    "preserves active filters after adding, editing, and deleting entries",
    build: () {
      final repo = MockAccountabilityRepo();
      final entry = _entry(1, "Matching entry");
      final addedEntry = _entry(2, "Matching entry added");
      final updatedEntry = _entry(1, "No longer matching");
      final results = <List<AccountabilityEntry>>[
        [entry],
        [entry, addedEntry],
        [],
        [],
      ];
      var searchCount = 0;
      registerFallbackValue(FakeAccountabilityEntryRequest());
      registerFallbackValue(FakeAccountabilityEntry());
      when(
        () => repo.searchEntries(
          searchQuery: "matching",
          identificationId: "food",
          limit: AccountabilityBloc.pageSize + 1,
          offset: 0,
        ),
      ).thenAnswer((_) async => results[searchCount++]);
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);
      when(() => repo.add(any(that: isA<AccountabilityEntryRequest>())))
          .thenAnswer((_) async => addedEntry);
      when(() => repo.update(any(that: isA<AccountabilityEntry>())))
          .thenAnswer((_) async => updatedEntry);
      when(() => repo.delete(any(that: isA<AccountabilityEntry>())))
          .thenAnswer((_) async {});

      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) async {
      bloc.add(const SearchAccountabilityEntries(
          query: "matching", identificationId: "food"));
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        AddAccountabilityEntry(
          AccountabilityEntryRequest(
              description: "Matching entry added",
              value: 20,
              createdAt: DateTime(2026)),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      bloc.add(UpdateAccountabilityEntry(_entry(1, "No longer matching")));
      await Future<void>.delayed(Duration.zero);
      bloc.add(DeleteAccountabilityEntry(_entry(1, "No longer matching")));
    },
    verify: (bloc) {
      verify(
        () => bloc.repo.searchEntries(
          searchQuery: "matching",
          identificationId: "food",
          limit: AccountabilityBloc.pageSize + 1,
          offset: 0,
        ),
      ).called(4);
    },
    expect: () => [
      for (var i = 0; i < 2; i++)
        isA<AccountabilityChanged>()
            .having((state) => state.searchQuery, "searchQuery", "matching")
            .having(
                (state) => state.identificationId, "identificationId", "food"),
      isA<AccountabilityChanged>()
          .having((state) => state.searchQuery, "searchQuery", "matching")
          .having((state) => state.identificationId, "identificationId", "food")
          .having(
              (state) => state.entryCreationVersion, "entryCreationVersion", 1),
      for (var i = 0; i < 5; i++)
        isA<AccountabilityChanged>()
            .having((state) => state.searchQuery, "searchQuery", "matching")
            .having(
                (state) => state.identificationId, "identificationId", "food"),
      isA<AccountabilityChanged>()
          .having((state) => state.searchQuery, "searchQuery", "matching")
          .having((state) => state.identificationId, "identificationId", "food")
          .having((state) => state.entries, "entries", isEmpty),
    ],
  );

  blocTest(
    "retorna uma lista contendo uma entrada armazenado",
    build: () {
      registerFallbackValue(FakeAccountabilityEntryRequest());
      final AccountabilityRepo repo = MockAccountabilityRepo();
      when(() => repo.add(any(that: isA<AccountabilityEntryRequest>())))
          .thenAnswer((_) async => FakeAccountabilityEntry());
      when(() => repo.getEntries(
          limit: any(named: "limit"),
          offset: any(named: "offset"))).thenAnswer((_) async => []);
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
      verify(() => bloc.repo.getEntries(
          limit: any(named: "limit"), offset: any(named: "offset"))).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );

  blocTest(
    "retorna a lista atualiazada quando uma entrada é removida",
    build: () {
      registerFallbackValue(FakeAccountabilityEntry());

      var repo = MockAccountabilityRepo();
      when(() => repo.delete(any(that: isA<AccountabilityEntry>())))
          .thenAnswer((_) async => {});
      when(() => repo.getEntries(
          limit: any(named: "limit"),
          offset: any(named: "offset"))).thenAnswer((_) async => []);
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
      verify(() => (bloc.repo as MockAccountabilityRepo).delete(any()))
          .called(1),
      verify(() => bloc.repo.getEntries(
          limit: any(named: "limit"), offset: any(named: "offset"))).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );

  blocTest(
    "does not report successful creation when persistence fails",
    build: () {
      registerFallbackValue(FakeAccountabilityEntryRequest());
      final repo = MockAccountabilityRepo();
      when(() => repo.add(any(that: isA<AccountabilityEntryRequest>())))
          .thenThrow(Exception("Save failed"));
      return AccountabilityBloc(repo: repo);
    },
    act: (bloc) => bloc.add(
      AddAccountabilityEntry(
        AccountabilityEntryRequest(
          description: "Entry",
          value: 10,
          createdAt: DateTime.now(),
        ),
      ),
    ),
    expect: () => <AccountabilityState>[],
    errors: () => [isA<Exception>()],
    verify: (bloc) {
      expect(bloc.state.entryCreationVersion, 0);
      verify(() => bloc.repo.add(any())).called(1);
    },
  );

  blocTest(
    "retorna a lista atualizada quando uma entrada é editada",
    build: () {
      registerFallbackValue(FakeAccountabilityEntry());
      var repo = MockAccountabilityRepo();
      when(() => repo.update(any(that: isA<AccountabilityEntry>())))
          .thenAnswer((_) async => FakeAccountabilityEntry());
      when(() => repo.getEntries(
          limit: any(named: "limit"),
          offset: any(named: "offset"))).thenAnswer((_) async => []);
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
      verify(() => (bloc.repo as MockAccountabilityRepo).update(any()))
          .called(1),
      verify(() => bloc.repo.getEntries(
          limit: any(named: "limit"), offset: any(named: "offset"))).called(1),
    },
    expect: () => [isA<AccountabilityChanged>()],
  );
}

AccountabilityEntry _entry(int id, String description) {
  final date = DateTime(2026);
  return AccountabilityEntry(
    id: id,
    description: description,
    value: id.toDouble(),
    createdAt: date,
    insertedAt: date,
    updatedAt: date,
  );
}
