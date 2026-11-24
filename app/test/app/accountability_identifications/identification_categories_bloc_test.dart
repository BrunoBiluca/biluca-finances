import 'package:biluca_financas/core/accountability/bloc/identification_categories_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/identification_categories_events.dart';
import 'package:biluca_financas/core/accountability/bloc/identification_categories_states.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../_mocks/mock_accountability_repo.dart';

void main() {
  late MockAccountabilityRepo repo;
  late AccountabilityIdentification identification;

  setUpAll(() {
    registerFallbackValue(
      AccountabilityIdentification('fallback', Colors.black),
    );
  });

  setUp(() {
    repo = MockAccountabilityRepo();
    identification = AccountabilityIdentification('Alimentação', Colors.green);
  });

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'loads the categories',
    build: () {
      when(() => repo.getIdentifications())
          .thenAnswer((_) async => [identification]);
      return IdentificationCategoriesBloc(repo: repo);
    },
    act: (bloc) => bloc.add(const LoadIdentificationCategories()),
    expect: () => [
      isA<IdentificationCategoriesChanged>()
          .having((state) => state.isLoading, 'isLoading', true),
      isA<IdentificationCategoriesChanged>()
          .having((state) => state.isLoading, 'isLoading', false)
          .having((state) => state.identifications, 'identifications',
              [identification]),
    ],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'creates a category and reloads',
    build: () {
      when(() => repo.addIdentification(identification))
          .thenAnswer((_) async => identification);
      when(() => repo.getIdentifications())
          .thenAnswer((_) async => [identification]);
      return IdentificationCategoriesBloc(repo: repo);
    },
    act: (bloc) => bloc.add(CreateIdentificationCategory(identification)),
    verify: (_) {
      verify(() => repo.addIdentification(identification)).called(1);
      verify(() => repo.getIdentifications()).called(1);
    },
    expect: () => [
      isA<IdentificationCategoriesChanged>().having(
          (state) => state.identifications,
          'identifications',
          [identification]),
    ],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'updates a category and reloads',
    build: () {
      when(() => repo.updateIdentification(identification))
          .thenAnswer((_) async {});
      when(() => repo.getIdentifications())
          .thenAnswer((_) async => [identification]);
      return IdentificationCategoriesBloc(repo: repo);
    },
    act: (bloc) => bloc.add(UpdateIdentificationCategory(identification)),
    verify: (_) {
      verify(() => repo.updateIdentification(identification)).called(1);
    },
    expect: () => [
      isA<IdentificationCategoriesChanged>(),
    ],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'creates a subcategory with the parent type',
    build: () {
      final parent = AccountabilityIdentification(
        'Receitas',
        Colors.green,
        type: AccountabilityIdentificationType.income,
      );
      final child = AccountabilityIdentification(
        'Salários',
        Colors.blue,
        parentId: parent.id,
        type: AccountabilityIdentificationType.expense,
      );
      when(() => repo.addIdentification(any())).thenAnswer((_) async => child);
      when(() => repo.getIdentifications())
          .thenAnswer((_) async => [parent, child]);
      return IdentificationCategoriesBloc(repo: repo);
    },
    seed: () {
      final parent = AccountabilityIdentification(
        'Receitas',
        Colors.green,
        type: AccountabilityIdentificationType.income,
      );
      return IdentificationCategoriesChanged(identifications: [parent]);
    },
    act: (bloc) {
      final parent = bloc.state.identifications.single;
      final child = AccountabilityIdentification(
        'Salários',
        Colors.blue,
        parentId: parent.id,
        type: AccountabilityIdentificationType.expense,
      );
      bloc.add(CreateIdentificationCategory(child));
    },
    verify: (_) {
      final captured = verify(() => repo.addIdentification(captureAny()))
          .captured
          .cast<AccountabilityIdentification>();
      expect(captured.single.type, AccountabilityIdentificationType.income);
    },
    expect: () => [isA<IdentificationCategoriesChanged>()],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'cascades the parent type to its children',
    build: () {
      when(() => repo.updateIdentification(any())).thenAnswer((_) async {});
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);
      return IdentificationCategoriesBloc(repo: repo);
    },
    seed: () {
      final parent = AccountabilityIdentification(
        'Despesas',
        Colors.green,
        type: AccountabilityIdentificationType.expense,
      );
      final child = AccountabilityIdentification(
        'Mercado',
        Colors.blue,
        parentId: parent.id,
        type: AccountabilityIdentificationType.expense,
      );
      return IdentificationCategoriesChanged(identifications: [parent, child]);
    },
    act: (bloc) {
      final parent = bloc.state.identifications.first;
      bloc.add(
        UpdateIdentificationCategory(
          parent.copyWith(type: AccountabilityIdentificationType.income),
        ),
      );
    },
    verify: (_) {
      final captured = verify(() => repo.updateIdentification(captureAny()))
          .captured
          .cast<AccountabilityIdentification>();
      expect(captured, hasLength(2));
      expect(
        captured.every(
          (item) => item.type == AccountabilityIdentificationType.income,
        ),
        isTrue,
      );
    },
    expect: () => [isA<IdentificationCategoriesChanged>()],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'normalizes a child type on update',
    build: () {
      when(() => repo.updateIdentification(any())).thenAnswer((_) async {});
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);
      return IdentificationCategoriesBloc(repo: repo);
    },
    seed: () {
      final parent = AccountabilityIdentification(
        'Receitas',
        Colors.green,
        type: AccountabilityIdentificationType.income,
      );
      final child = AccountabilityIdentification(
        'Salários',
        Colors.blue,
        parentId: parent.id,
        type: AccountabilityIdentificationType.expense,
      );
      return IdentificationCategoriesChanged(identifications: [parent, child]);
    },
    act: (bloc) {
      final child = bloc.state.identifications.last;
      bloc.add(UpdateIdentificationCategory(child));
    },
    verify: (_) {
      final captured = verify(() => repo.updateIdentification(captureAny()))
          .captured
          .cast<AccountabilityIdentification>();
      expect(captured.single.type, AccountabilityIdentificationType.income);
    },
    expect: () => [isA<IdentificationCategoriesChanged>()],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'increments the creation version after creating',
    build: () {
      when(() => repo.addIdentification(identification))
          .thenAnswer((_) async => identification);
      when(() => repo.getIdentifications())
          .thenAnswer((_) async => [identification]);
      return IdentificationCategoriesBloc(repo: repo);
    },
    act: (bloc) => bloc.add(CreateIdentificationCategory(identification)),
    expect: () => [
      isA<IdentificationCategoriesChanged>()
          .having((state) => state.creationVersion, 'creationVersion', 1)
          .having((state) => state.updateVersion, 'updateVersion', 0)
          .having((state) => state.deletionVersion, 'deletionVersion', 0),
    ],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'increments the update version after editing',
    build: () {
      when(() => repo.updateIdentification(any())).thenAnswer((_) async {});
      when(() => repo.getIdentifications())
          .thenAnswer((_) async => [identification]);
      return IdentificationCategoriesBloc(repo: repo);
    },
    act: (bloc) => bloc.add(UpdateIdentificationCategory(identification)),
    expect: () => [
      isA<IdentificationCategoriesChanged>()
          .having((state) => state.creationVersion, 'creationVersion', 0)
          .having((state) => state.updateVersion, 'updateVersion', 1)
          .having((state) => state.deletionVersion, 'deletionVersion', 0),
    ],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'increments the deletion version after deleting',
    build: () {
      when(() => repo.deleteIdentification(identification.id))
          .thenAnswer((_) async {});
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);
      return IdentificationCategoriesBloc(repo: repo);
    },
    act: (bloc) => bloc.add(DeleteIdentificationCategory(identification.id)),
    expect: () => [
      isA<IdentificationCategoriesChanged>()
          .having((state) => state.creationVersion, 'creationVersion', 0)
          .having((state) => state.updateVersion, 'updateVersion', 0)
          .having((state) => state.deletionVersion, 'deletionVersion', 1),
    ],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'keeps the versions when loading',
    build: () {
      when(() => repo.getIdentifications())
          .thenAnswer((_) async => [identification]);
      return IdentificationCategoriesBloc(repo: repo);
    },
    seed: () => IdentificationCategoriesChanged(
      identifications: [identification],
      creationVersion: 2,
      updateVersion: 3,
      deletionVersion: 4,
    ),
    act: (bloc) => bloc.add(const LoadIdentificationCategories()),
    expect: () => [
      isA<IdentificationCategoriesChanged>()
          .having((state) => state.isLoading, 'isLoading', true)
          .having((state) => state.creationVersion, 'creationVersion', 2),
      isA<IdentificationCategoriesChanged>()
          .having((state) => state.isLoading, 'isLoading', false)
          .having((state) => state.creationVersion, 'creationVersion', 2)
          .having((state) => state.updateVersion, 'updateVersion', 3)
          .having((state) => state.deletionVersion, 'deletionVersion', 4),
    ],
  );

  blocTest<IdentificationCategoriesBloc, IdentificationCategoriesState>(
    'deletes a category and reloads',
    build: () {
      when(() => repo.deleteIdentification(identification.id))
          .thenAnswer((_) async {});
      when(() => repo.getIdentifications()).thenAnswer((_) async => []);
      return IdentificationCategoriesBloc(repo: repo);
    },
    act: (bloc) => bloc.add(DeleteIdentificationCategory(identification.id)),
    verify: (_) {
      verify(() => repo.deleteIdentification(identification.id)).called(1);
    },
    expect: () => [
      isA<IdentificationCategoriesChanged>()
          .having((state) => state.identifications, 'identifications', isEmpty),
    ],
  );
}
