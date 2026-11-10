import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/validators/identification_hierarchy_rules.dart';
import 'package:biluca_financas/core/accountability/validators/identification_status_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IdentificationHierarchyRules', () {
    late AccountabilityIdentification root;
    late AccountabilityIdentification otherRoot;
    late AccountabilityIdentification child;
    late AccountabilityIdentification discontinuedRoot;
    late List<AccountabilityIdentification> all;

    setUp(() {
      root = AccountabilityIdentification('Alimentação', Colors.green);
      otherRoot = AccountabilityIdentification('Transporte', Colors.blue);
      child = AccountabilityIdentification(
        'Restaurante',
        Colors.orange,
        parentId: root.id,
      );
      discontinuedRoot = AccountabilityIdentification(
        'Categoria antiga',
        Colors.grey,
        discontinued: true,
      );
      all = [root, otherRoot, child, discontinuedRoot];
    });

    test('only offers root categories as parents', () {
      final available = IdentificationHierarchyRules.availableParents(
        editedId: child.id,
        editedDiscontinued: false,
        identifications: all,
      );

      expect(available.map((item) => item.id),
          containsAll([root.id, otherRoot.id]));
      expect(available.map((item) => item.id), isNot(contains(child.id)));
      expect(available.map((item) => item.id),
          isNot(contains(discontinuedRoot.id)));
    });

    test('offers discontinued roots for a discontinued category', () {
      final discontinuedChild = child.copyWith(discontinued: true);
      final available = IdentificationHierarchyRules.availableParents(
        editedId: discontinuedChild.id,
        editedDiscontinued: true,
        identifications: [root, otherRoot, discontinuedChild, discontinuedRoot],
      );

      expect(available.map((item) => item.id), contains(discontinuedRoot.id));
    });

    test('rejects a category as its own parent', () {
      final error = IdentificationHierarchyRules.validateParent(
        parentId: root.id,
        editedId: root.id,
        editedDiscontinued: false,
        identifications: all,
      );

      expect(error, isNotNull);
    });

    test('rejects a parent that is already a subcategory', () {
      final error = IdentificationHierarchyRules.validateParent(
        parentId: child.id,
        editedId: otherRoot.id,
        editedDiscontinued: false,
        identifications: all,
      );

      expect(error, isNotNull);
    });

    test('rejects a category that has children becoming a child', () {
      final error = IdentificationHierarchyRules.validateParent(
        parentId: otherRoot.id,
        editedId: root.id,
        editedDiscontinued: false,
        identifications: all,
      );

      expect(error, isNotNull);
      expect(IdentificationHierarchyRules.hasChildren(root.id, all), isTrue);
    });

    test('rejects an active category under a discontinued parent', () {
      final error = IdentificationHierarchyRules.validateParent(
        parentId: discontinuedRoot.id,
        editedId: otherRoot.id,
        editedDiscontinued: false,
        identifications: all,
      );

      expect(error, isNotNull);
    });

    test('accepts a valid root parent', () {
      final error = IdentificationHierarchyRules.validateParent(
        parentId: otherRoot.id,
        editedId: child.id,
        editedDiscontinued: false,
        identifications: all,
      );

      expect(error, isNull);
    });
  });

  group('IdentificationStatusRules', () {
    test('blocks discontinuing a root with active children', () {
      final root = AccountabilityIdentification('Alimentação', Colors.green);
      final child = AccountabilityIdentification(
        'Restaurante',
        Colors.orange,
        parentId: root.id,
      );

      final error = IdentificationStatusRules.validateTransition(
        identification: root,
        nextDiscontinued: true,
        identifications: [root, child],
      );

      expect(error, isNotNull);
    });

    test('allows discontinuing a root after its children are discontinued', () {
      final root = AccountabilityIdentification('Alimentação', Colors.green);
      final child = AccountabilityIdentification(
        'Restaurante',
        Colors.orange,
        parentId: root.id,
        discontinued: true,
      );

      final error = IdentificationStatusRules.validateTransition(
        identification: root,
        nextDiscontinued: true,
        identifications: [root, child],
      );

      expect(error, isNull);
    });

    test('allows discontinuing a root after its children are promoted', () {
      final root = AccountabilityIdentification('Alimentação', Colors.green);
      final child = AccountabilityIdentification('Restaurante', Colors.orange);

      final error = IdentificationStatusRules.validateTransition(
        identification: root,
        nextDiscontinued: true,
        identifications: [root, child],
      );

      expect(error, isNull);
    });

    test('blocks reactivating a child whose parent is discontinued', () {
      final parent = AccountabilityIdentification(
        'Alimentação',
        Colors.green,
        discontinued: true,
      );
      final child = AccountabilityIdentification(
        'Restaurante',
        Colors.orange,
        parentId: parent.id,
        discontinued: true,
      );

      final error = IdentificationStatusRules.validateTransition(
        identification: child,
        nextDiscontinued: false,
        identifications: [parent, child],
      );

      expect(error, isNotNull);
    });

    test('allows reactivating a child whose parent is active', () {
      final parent = AccountabilityIdentification('Alimentação', Colors.green);
      final child = AccountabilityIdentification(
        'Restaurante',
        Colors.orange,
        parentId: parent.id,
        discontinued: true,
      );

      final error = IdentificationStatusRules.validateTransition(
        identification: child,
        nextDiscontinued: false,
        identifications: [parent, child],
      );

      expect(error, isNull);
    });
  });
}
