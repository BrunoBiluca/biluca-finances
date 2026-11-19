import 'package:biluca_financas/core/backup/models/backup_credentials.dart';
import 'package:equatable/equatable.dart';

class BackupSettings extends Equatable {
  final bool configured;
  final String? accountEmail;
  final DateTime? connectedAt;
  final BackupCredentials? credentials;

  const BackupSettings({
    required this.configured,
    this.accountEmail,
    this.connectedAt,
    this.credentials,
  });

  static const BackupSettings notConfigured = BackupSettings(configured: false);

  factory BackupSettings.fromJson(Map<String, dynamic> json) {
    final credentials = json['credentials'];
    return BackupSettings(
      configured: json['configured'] as bool? ?? false,
      accountEmail: json['accountEmail'] as String?,
      connectedAt: json['connectedAt'] == null
          ? null
          : DateTime.parse(json['connectedAt'] as String).toUtc(),
      credentials: credentials is Map<String, dynamic>
          ? BackupCredentials.fromJson(credentials)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'configured': configured,
      if (accountEmail != null) 'accountEmail': accountEmail,
      if (connectedAt != null) 'connectedAt': connectedAt!.toUtc().toIso8601String(),
      if (credentials != null) 'credentials': credentials!.toJson(),
    };
  }

  @override
  List<Object?> get props => [configured, accountEmail, connectedAt, credentials];
}
