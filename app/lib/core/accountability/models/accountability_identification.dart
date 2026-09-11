import 'dart:convert';

import 'package:biluca_financas/core/accountability/models/accountability_identification_type.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AccountabilityIdentification {
  final String id;
  String description;
  Color color;
  IconData icon;

  AccountabilityIdentificationType type;

  AccountabilityIdentification._(this.id, this.description, this.color, this.icon, this.type);

  factory AccountabilityIdentification(String description, Color color) {
    return AccountabilityIdentification._(
      const Uuid().v4(),
      description,
      color,
      Icons.help_outline,
      AccountabilityIdentificationType.expense,
    );
  }

  factory AccountabilityIdentification.fromMap(Map<String, dynamic> m) {
    var map = {...m};

    if (map['icon'] is String) {
      map['icon'] = json.decode(map['icon'] as String);
    }

    return AccountabilityIdentification._(
      map['id'],
      map['description'],
      Color(map['color']),
      IconData(
        map['icon']['code'],
        fontFamily: map['icon']['fontFamily'],
        fontPackage: map['icon']['fontPackage'],
      ),
      AccountabilityIdentificationType.values.firstWhere(
        (element) => element.name == map['type'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'color': color.value,
      'icon': {'code': icon.codePoint, 'fontFamily': icon.fontFamily, 'fontPackage': icon.fontPackage},
      'type': type.name
    };
  }
}
