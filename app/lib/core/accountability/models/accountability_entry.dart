import 'accountability_identification.dart';
import 'accountability_table_entry.dart';

class AccountabilityEntry implements AccountabilityTableEntry {
  final int id;
  @override
  String description;
  @override
  double value;
  String? identificationId;
  @override
  AccountabilityIdentification? identification;
  @override
  final DateTime createdAt;
  @override
  final DateTime insertedAt;
  final DateTime updatedAt;
  @override
  String? descriptionAlt;

  AccountabilityEntry({
    required this.id,
    required this.description,
    required this.value,
    required this.createdAt,
    required this.insertedAt,
    required this.updatedAt,
    this.identificationId,
    this.descriptionAlt,
  });

  factory AccountabilityEntry.fromMap(Map<String, dynamic> map) {
    var entry = AccountabilityEntry(
      id: map['id'],
      description: map['description'],
      value: map['value'],
      identificationId: map['identification_id'],
      createdAt: DateTime.parse(map['createdAt']),
      insertedAt: DateTime.parse(map['insertedAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      descriptionAlt: map['description_alt'],
    );

    if (map['identification'] != null) {
      entry.identification = AccountabilityIdentification.fromMap(map['identification']);
    }
    return entry;
  }
}
