import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AccountabilityIdentification {
  final String id;
  String description;
  Color color;

  AccountabilityIdentification._(this.id, this.description, this.color);

  factory AccountabilityIdentification(String description, Color color) {
    return AccountabilityIdentification._(const Uuid().v4(), description, color);
  }

  factory AccountabilityIdentification.fromMap(Map<String, dynamic> map) {
    return AccountabilityIdentification._(
      map['id'],
      map['description'],
      Color(map['color']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'color': color.value,
    };
  }
}
