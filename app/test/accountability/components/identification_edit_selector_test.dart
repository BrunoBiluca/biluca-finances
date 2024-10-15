
import 'package:biluca_financas/accountability/bloc/bloc.dart';
import 'package:biluca_financas/accountability/bloc/events.dart';
import 'package:biluca_financas/accountability/components/identification_edit_selector.dart';
import 'package:biluca_financas/accountability/models/identification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mock_accountability_repo.dart';

void main() {
  testWidgets("deve exibir mensagem quando não houver identificações", (tester) async {
    var repo = MockAccountabilityRepo();
    var bloc = AccountabilityBloc(repo: repo);

    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityIdentificationSelector(accountabilityBloc: bloc),
        ),
      ),
    );

    expect(find.byKey(const Key("no-identification-found")), findsOneWidget);
  });

  testWidgets("deve exibir identificações quando essas existem", (tester) async {
    var repo = MockAccountabilityRepo();
    when(() => repo.getEntries(limit: any(named: "limit"))).thenAnswer((_) async => []);
    when(() => repo.getIdentifications()).thenAnswer((_) async => [
          AccountabilityIdentification("identificação 1", Colors.black),
          AccountabilityIdentification("identificação 2", Colors.black),
          AccountabilityIdentification("identificação 3", Colors.black),
        ]);

    var accountabilityBloc = AccountabilityBloc(repo: repo)..add(FetchAccountabilityEntries());

    await tester.pump(const Duration(microseconds: 100));

    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityIdentificationSelector(accountabilityBloc: accountabilityBloc),
        ),
      ),
    );

    expect(find.text("identificação 1"), findsOneWidget);
    expect(find.text("identificação 2"), findsOneWidget);
    expect(find.text("identificação 3"), findsOneWidget);
  });
}
