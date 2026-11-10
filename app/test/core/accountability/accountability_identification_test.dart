import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> map({bool legacy = false}) {
    return {
      'id': 'identification-1',
      'description': 'Alimentação',
      'color': Colors.green.toARGB32(),
      'icon': {
        'code': Icons.restaurant.codePoint,
        'fontFamily': Icons.restaurant.fontFamily,
        'fontPackage': Icons.restaurant.fontPackage,
      },
      'type': 'expense',
      if (!legacy) 'parent_id': 'parent-1',
      if (!legacy) 'discontinued': 1,
    };
  }

  test('reads a legacy map as an active root category', () {
    final identification =
        AccountabilityIdentification.fromMap(map(legacy: true));

    expect(identification.parentId, isNull);
    expect(identification.discontinued, isFalse);
    expect(identification.type, AccountabilityIdentificationType.expense);
  });

  test('reads parent and discontinued status from a map', () {
    final identification = AccountabilityIdentification.fromMap(map());

    expect(identification.parentId, 'parent-1');
    expect(identification.discontinued, isTrue);
  });

  test('writes parent and discontinued status to a map', () {
    final identification = AccountabilityIdentification(
      'Viagem',
      Colors.blue,
      parentId: 'parent-1',
      discontinued: true,
      type: AccountabilityIdentificationType.income,
    );

    final map = identification.toMap();

    expect(map['parent_id'], 'parent-1');
    expect(map['discontinued'], 1);
    expect(map['type'], 'income');
  });

  test('copies the category keeping its id', () {
    final identification = AccountabilityIdentification('Viagem', Colors.blue);
    final updated = identification.copyWith(
      description: 'Viagem atualizada',
      parentId: 'parent-1',
      discontinued: true,
    );

    expect(updated.id, identification.id);
    expect(updated.description, 'Viagem atualizada');
    expect(updated.parentId, 'parent-1');
    expect(updated.discontinued, isTrue);
    expect(updated.copyWith(clearParent: true).parentId, isNull);
  });
}
