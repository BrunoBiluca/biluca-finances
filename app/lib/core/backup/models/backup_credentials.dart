import 'package:equatable/equatable.dart';

class BackupCredentials extends Equatable {
  final String accessToken;
  final String tokenType;
  final DateTime expiry;
  final String? refreshToken;
  final List<String> scopes;

  const BackupCredentials({
    required this.accessToken,
    required this.tokenType,
    required this.expiry,
    required this.scopes,
    this.refreshToken,
  });

  factory BackupCredentials.fromJson(Map<String, dynamic> json) {
    return BackupCredentials(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiry: DateTime.parse(json['expiry'] as String).toUtc(),
      refreshToken: json['refreshToken'] as String?,
      scopes: (json['scopes'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'tokenType': tokenType,
      'expiry': expiry.toUtc().toIso8601String(),
      if (refreshToken != null) 'refreshToken': refreshToken,
      'scopes': scopes,
    };
  }

  @override
  List<Object?> get props => [accessToken, tokenType, expiry, refreshToken, scopes];
}
