import 'package:biluca_financas/core/accountability/bloc/accountability_bloc.dart';
import 'package:biluca_financas/core/accountability/bloc/accountability_events.dart';
import 'package:biluca_financas/app/accountability_table/widgets/accountability_identification_selector.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/common/ui/text_ballon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../_mocks/mock_accountability_repo.dart';

void main() {
  testWidgets("deve exibir mensagem quando não houver identificações",
      (tester) async {
    var repo = MockAccountabilityRepo();
    var bloc = AccountabilityBloc(repo: repo);

    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityIdentificationSelector(
            accountabilityBloc: bloc,
            identifications: bloc.state.identifications,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key("no-identification-found")), findsOneWidget);
  });

  testWidgets("deve exibir identificações quando essas existem",
      (tester) async {
    var repo = MockAccountabilityRepo();
    final identifications = [
      AccountabilityIdentification("identificação 1", Colors.green)
        ..icon = Icons.restaurant,
      AccountabilityIdentification("identificação 2", Colors.blue),
      AccountabilityIdentification("identificação 3", Colors.orange),
    ];
    when(() => repo.getEntries(limit: any(named: "limit")))
        .thenAnswer((_) async => []);
    when(() => repo.getIdentifications())
        .thenAnswer((_) async => identifications);

    var accountabilityBloc = AccountabilityBloc(repo: repo)
      ..add(FetchAccountabilityEntries());

    await tester.pump(const Duration(microseconds: 100));

    await tester.pumpWidget(
      MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          body: AccountabilityIdentificationSelector(
            accountabilityBloc: accountabilityBloc,
            identifications: accountabilityBloc.state.identifications,
          ),
        ),
      ),
    );

    expect(find.text("identificação 1"), findsOneWidget);
    expect(find.text("identificação 2"), findsOneWidget);
    expect(find.text("identificação 3"), findsOneWidget);

    final firstItem =
        find.byKey(Key('identification-item-${identifications[0].id}'));
    final ballon = tester.widget<TextBallon>(firstItem);
    expect(ballon.tintedStyle, isTrue);
    final decoration = tester.widget<DecoratedBox>(
      find.descendant(of: firstItem, matching: find.byType(DecoratedBox)),
    );
    expect(
      (decoration.decoration as BoxDecoration).color,
      identifications[0].color.withValues(alpha: 0.16),
    );
    final icon = tester.widget<Icon>(
      find.descendant(of: firstItem, matching: find.byIcon(Icons.restaurant)),
    );
    expect(icon.color, identifications[0].color);
  });
}
