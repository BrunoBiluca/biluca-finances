import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';
import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';

class IdentificationTypeRules {
  static AccountabilityIdentification? parentOf(
    String? parentId,
    List<AccountabilityIdentification> identifications,
  ) {
    if (parentId == null) return null;
    for (final candidate in identifications) {
      if (candidate.id == parentId) return candidate;
    }
    return null;
  }

  static AccountabilityIdentificationType? inheritedType({
    required String? parentId,
    required List<AccountabilityIdentification> identifications,
  }) {
    return parentOf(parentId, identifications)?.type;
  }

  static String? validateType({
    required String? parentId,
    required AccountabilityIdentificationType type,
    required List<AccountabilityIdentification> identifications,
  }) {
    final parent = parentOf(parentId, identifications);
    if (parent == null) return null;
    if (parent.type != type) {
      return 'O tipo da subcategoria deve ser igual ao tipo da categoria pai.';
    }
    return null;
  }

  static List<AccountabilityIdentification> childrenOf(
    String identificationId,
    List<AccountabilityIdentification> identifications,
  ) {
    return identifications
        .where((item) => item.parentId == identificationId)
        .toList();
  }

  static List<AccountabilityIdentification> withCascadedType({
    required AccountabilityIdentification parent,
    required List<AccountabilityIdentification> identifications,
  }) {
    return [
      parent,
      ...childrenOf(parent.id, identifications).map(
        (child) => child.copyWith(type: parent.type),
      ),
    ];
  }
}
