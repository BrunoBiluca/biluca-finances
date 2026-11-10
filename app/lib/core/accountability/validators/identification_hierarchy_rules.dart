import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

class IdentificationHierarchyRules {
  static bool hasChildren(
    String categoryId,
    List<AccountabilityIdentification> identifications,
  ) {
    return identifications.any((item) => item.parentId == categoryId);
  }

  static bool canBeParent({
    required AccountabilityIdentification candidate,
    required String? editedId,
    required bool editedDiscontinued,
    required List<AccountabilityIdentification> identifications,
  }) {
    if (candidate.id == editedId) return false;
    if (candidate.parentId != null) return false;
    if (!editedDiscontinued && candidate.discontinued) return false;
    return true;
  }

  static List<AccountabilityIdentification> availableParents({
    required String? editedId,
    required bool editedDiscontinued,
    required List<AccountabilityIdentification> identifications,
  }) {
    final options = identifications
        .where(
          (candidate) => canBeParent(
            candidate: candidate,
            editedId: editedId,
            editedDiscontinued: editedDiscontinued,
            identifications: identifications,
          ),
        )
        .toList()
      ..sort(
          (first, second) => first.description.compareTo(second.description));
    return options;
  }

  static String? validateParent({
    required String? parentId,
    required String? editedId,
    required bool editedDiscontinued,
    required List<AccountabilityIdentification> identifications,
  }) {
    if (parentId == null) return null;

    if (parentId == editedId) {
      return 'Uma categoria não pode ser filha de si mesma.';
    }

    AccountabilityIdentification? parent;
    for (final candidate in identifications) {
      if (candidate.id == parentId) {
        parent = candidate;
        break;
      }
    }

    if (parent == null) {
      return 'A categoria pai selecionada não existe.';
    }

    if (parent.parentId != null) {
      return 'A categoria pai precisa ser uma categoria raiz.';
    }

    if (!editedDiscontinued && parent.discontinued) {
      return 'Uma categoria ativa não pode ter uma categoria pai descontinuada.';
    }

    if (editedId != null && hasChildren(editedId, identifications)) {
      return 'Uma categoria com subcategorias não pode ser filha de outra categoria.';
    }

    return null;
  }
}
