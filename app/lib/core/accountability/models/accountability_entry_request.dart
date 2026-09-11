import 'accountability_identification.dart';

class AccountabilityEntryRequest {
  String description;
  double value;
  AccountabilityIdentification? identification;
  DateTime createdAt;
  String? descriptionAlt;

  AccountabilityEntryRequest({
    required this.description,
    required this.value,
    this.identification,
    required this.createdAt,
  });
}
