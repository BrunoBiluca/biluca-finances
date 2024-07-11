import 'identification.dart';

class AccountabilityEntryRequest {
  String description;
  double value;
  AccountabilityIdentification? identification;
  DateTime createdAt;

  AccountabilityEntryRequest({
    required this.description,
    required this.value,
    this.identification,
    required this.createdAt,
  });
}
