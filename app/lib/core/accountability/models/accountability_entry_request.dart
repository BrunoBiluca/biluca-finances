import 'accountability_identification.dart';
import 'accountability_table_entry.dart';

class AccountabilityEntryRequest implements AccountabilityTableEntry {
  @override
  String description;
  @override
  double value;
  @override
  AccountabilityIdentification? identification;
  @override
  DateTime createdAt;
  @override
  String? descriptionAlt;

  AccountabilityEntryRequest({
    required this.description,
    required this.value,
    this.identification,
    required this.createdAt,
  });

  @override
  DateTime? get insertedAt => null;
}
