import 'package:biluca_financas/core/accountability/models/accountability_identification.dart';

class IdentificationAvailabilityRules {
  static List<AccountabilityIdentification> optionsForSelection({
    required List<AccountabilityIdentification> identifications,
    String? currentIdentificationId,
  }) {
    return identifications
        .where(
          (item) => !item.discontinued || item.id == currentIdentificationId,
        )
        .toList();
  }

  static List<AccountabilityIdentification> availableForPrediction(
    List<AccountabilityIdentification> identifications,
  ) {
    return identifications.where((item) => !item.discontinued).toList();
  }
}
