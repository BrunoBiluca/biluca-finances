import 'identification.dart';

class AccountabilityEntry {
  final int id;
  String description;
  double value;
  String? identificationId;
  AccountabilityIdentification? identification;
  final DateTime createdAt;
  final DateTime insertedAt;
  final DateTime updatedAt;

  AccountabilityEntry({
    required this.id,
    required this.description,
    required this.value,
    required this.createdAt,
    required this.insertedAt,
    required this.updatedAt,
    this.identificationId,
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
    );

    var ai = <String, dynamic>{};
    for (var key in map.keys) {
      if (key.startsWith('ai_') && map[key] != null) {
        ai[key.replaceFirst('ai_', '')] = map[key];
      }
    }
    
    if (ai.isNotEmpty) {
      entry.identification = AccountabilityIdentification.fromMap(ai);  
    }
    return entry;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'insertedAt': insertedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'identification_id': identification?.id,
    };
  }
}
