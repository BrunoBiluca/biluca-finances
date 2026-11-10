import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/identification_consolidation.dart';
import 'package:biluca_financas/core/accountability/validators/identification_availability_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offers active categories and the current discontinued category', () {
    final active = AccountabilityIdentification('Ativa', Colors.green);
    final discontinued = AccountabilityIdentification(
      'Descontinuada',
      Colors.grey,
      discontinued: true,
    );

    final options = IdentificationAvailabilityRules.optionsForSelection(
      identifications: [active, discontinued],
      currentIdentificationId: discontinued.id,
    );

    expect(options.map((item) => item.id), [active.id, discontinued.id]);
  });

  test('does not offer other discontinued categories', () {
    final active = AccountabilityIdentification('Ativa', Colors.green);
    final discontinued = AccountabilityIdentification(
      'Descontinuada',
      Colors.grey,
      discontinued: true,
    );

    final options = IdentificationAvailabilityRules.optionsForSelection(
      identifications: [active, discontinued],
    );

    expect(options.map((item) => item.id), [active.id]);
  });

  test('prediction ignores discontinued categories', () {
    final active = AccountabilityIdentification('Ativa', Colors.green);
    final discontinued = AccountabilityIdentification(
      'Descontinuada',
      Colors.grey,
      discontinued: true,
    );

    final options = IdentificationAvailabilityRules.availableForPrediction(
      [active, discontinued],
    );

    expect(options.map((item) => item.id), [active.id]);
  });

  test('calculates the four consolidation values', () {
    final root = AccountabilityIdentification('Raiz', Colors.green);
    final child = AccountabilityIdentification(
      'Filha',
      Colors.blue,
      parentId: root.id,
    );
    final discontinued = AccountabilityIdentification(
      'Antiga',
      Colors.grey,
      discontinued: true,
    );

    final consolidation = IdentificationConsolidation.fromIdentifications(
      [root, child, discontinued],
    );

    expect(consolidation.total, 3);
    expect(consolidation.parents, 2);
    expect(consolidation.subcategories, 1);
    expect(consolidation.discontinued, 1);
  });
}
