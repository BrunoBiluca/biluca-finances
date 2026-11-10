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

  String? parentId;
  bool discontinued;

  AccountabilityIdentification._(
    this.id,
    this.description,
    this.color,
    this.icon,
    this.type, {
    this.parentId,
    this.discontinued = false,
  });

  factory AccountabilityIdentification(
    String description,
    Color color, {
    String? parentId,
    bool discontinued = false,
    AccountabilityIdentificationType type =
        AccountabilityIdentificationType.expense,
  }) {
    return AccountabilityIdentification._(
      const Uuid().v4(),
      description,
      color,
      Icons.help_outline,
      type,
      parentId: parentId,
      discontinued: discontinued,
    );
  }

  factory AccountabilityIdentification.fromMap(Map<String, dynamic> m) {
    var map = {...m};

    if (map['icon'] is String) {
      map['icon'] = json.decode(map['icon'] as String);
    }

    final discontinued = map['discontinued'];

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
      parentId: map['parent_id'] as String?,
      discontinued: discontinued == true || discontinued == 1,
    );
  }

  bool get isRoot => parentId == null;

  bool get isSelectableForEntries => !discontinued;

  AccountabilityIdentification copyWith({
    String? description,
    Color? color,
    IconData? icon,
    AccountabilityIdentificationType? type,
    String? parentId,
    bool clearParent = false,
    bool? discontinued,
  }) {
    return AccountabilityIdentification._(
      id,
      description ?? this.description,
      color ?? this.color,
      icon ?? this.icon,
      type ?? this.type,
      parentId: clearParent ? null : (parentId ?? this.parentId),
      discontinued: discontinued ?? this.discontinued,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'color': color.toARGB32(),
      'icon': {
        'code': icon.codePoint,
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
      },
      'type': type.name,
      'parent_id': parentId,
      'discontinued': discontinued ? 1 : 0,
    };
  }
}
