import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

class IdentificationConsolidation {
  final int total;
  final int parents;
  final int subcategories;
  final int discontinued;

  const IdentificationConsolidation({
    required this.total,
    required this.parents,
    required this.subcategories,
    required this.discontinued,
  });

  factory IdentificationConsolidation.fromIdentifications(
    List<AccountabilityIdentification> identifications,
  ) {
    return IdentificationConsolidation(
      total: identifications.length,
      parents: identifications.where((item) => item.parentId == null).length,
      subcategories:
          identifications.where((item) => item.parentId != null).length,
      discontinued: identifications.where((item) => item.discontinued).length,
    );
  }
}
