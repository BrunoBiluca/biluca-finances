import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:biluca_financas/core/accountability/validators/identification_type_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AccountabilityIdentification parent;
  late AccountabilityIdentification child;

  setUp(() {
    parent = AccountabilityIdentification(
      'Receitas',
      Colors.green,
      type: AccountabilityIdentificationType.income,
    );
    child = AccountabilityIdentification(
      'Salários',
      Colors.blue,
      parentId: parent.id,
      type: AccountabilityIdentificationType.income,
    );
  });

  test('inherits the parent type', () {
    final inherited = IdentificationTypeRules.inheritedType(
      parentId: parent.id,
      identifications: [parent, child],
    );

    expect(inherited, AccountabilityIdentificationType.income);
    expect(
      IdentificationTypeRules.inheritedType(
        parentId: null,
        identifications: [parent, child],
      ),
      isNull,
    );
  });

  test('validates that the child type matches the parent', () {
    final valid = IdentificationTypeRules.validateType(
      parentId: parent.id,
      type: AccountabilityIdentificationType.income,
      identifications: [parent, child],
    );
    final invalid = IdentificationTypeRules.validateType(
      parentId: parent.id,
      type: AccountabilityIdentificationType.expense,
      identifications: [parent, child],
    );

    expect(valid, isNull);
    expect(invalid, isNotNull);
  });

  test('cascades the parent type to its children', () {
    final updatedParent = parent.copyWith(
      type: AccountabilityIdentificationType.expense,
    );
    final cascaded = IdentificationTypeRules.withCascadedType(
      parent: updatedParent,
      identifications: [parent, child],
    );

    expect(cascaded, hasLength(2));
    expect(
      cascaded.firstWhere((item) => item.id == child.id).type,
      AccountabilityIdentificationType.expense,
    );
  });
}
