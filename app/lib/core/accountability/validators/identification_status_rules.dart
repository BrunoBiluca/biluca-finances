import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

class IdentificationStatusRules {
  static bool hasActiveChildren(
    String categoryId,
    List<AccountabilityIdentification> identifications,
  ) {
    return identifications.any(
      (item) => item.parentId == categoryId && !item.discontinued,
    );
  }

  static String? validateTransition({
    required AccountabilityIdentification identification,
    required bool nextDiscontinued,
    required List<AccountabilityIdentification> identifications,
  }) {
    if (nextDiscontinued == identification.discontinued) {
      return null;
    }

    if (nextDiscontinued &&
        hasActiveChildren(identification.id, identifications)) {
      return 'Esta categoria possui subcategorias ativas. Promova-as a categorias raiz ou descontinue-as antes de descontinuar esta categoria.';
    }

    if (!nextDiscontinued) {
      final parentId = identification.parentId;
      if (parentId != null) {
        for (final candidate in identifications) {
          if (candidate.id == parentId && candidate.discontinued) {
            return 'A categoria pai está descontinuada. Reative-a ou remova o vínculo antes de reativar esta categoria.';
          }
        }
      }
    }

    return null;
  }
}
