import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:equatable/equatable.dart';

class PublishedRelease extends Equatable {
  final AppVersion version;
  final String tagName;
  final String installerName;
  final String installerUrl;

  const PublishedRelease({
    required this.version,
    required this.tagName,
    required this.installerName,
    required this.installerUrl,
  });

  @override
  List<Object?> get props => [version, tagName, installerName, installerUrl];
}
