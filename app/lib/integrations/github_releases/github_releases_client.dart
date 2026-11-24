import 'dart:convert';

import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:biluca_financas/core/app_update/models/published_release.dart';
import 'package:http/http.dart';

class GithubReleasesException implements Exception {
  final String message;

  const GithubReleasesException(this.message);

  @override
  String toString() => message;
}

class GithubReleasesClient {
  static const String defaultLatestReleaseUrl =
      'https://api.github.com/repos/BrunoBiluca/biluca-finances/releases/latest';

  static Uri get defaultLatestReleaseUri => Uri.parse(defaultLatestReleaseUrl);

  static const String installerPrefix = 'biluca-financas-setup-';
  static const String installerExtension = '.exe';

  final Client http;
  final Uri latestReleaseUri;
  final Duration timeout;

  GithubReleasesClient({
    required this.http,
    Uri? latestReleaseUri,
    this.timeout = const Duration(seconds: 10),
  }) : latestReleaseUri = latestReleaseUri ?? defaultLatestReleaseUri;

  Future<PublishedRelease> fetchLatestRelease() async {
    final Response response;
    try {
      response = await http.get(
        latestReleaseUri,
        headers: const {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          'User-Agent': 'biluca-financas',
        },
      ).timeout(timeout);
    } on Exception catch (error) {
      throw GithubReleasesException(
        'Não foi possível consultar as versões publicadas: $error',
      );
    }

    if (response.statusCode == 404) {
      throw const GithubReleasesException(
        'Nenhuma versão publicada foi encontrada no GitHub.',
      );
    }
    if (response.statusCode == 403) {
      throw const GithubReleasesException(
        'O limite de consultas ao GitHub foi atingido. Tente novamente mais tarde.',
      );
    }
    if (response.statusCode != 200) {
      throw GithubReleasesException(
        'Falha ao consultar as versões publicadas (HTTP ${response.statusCode}).',
      );
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on Exception {
      throw const GithubReleasesException(
        'A resposta das versões publicadas não pôde ser interpretada.',
      );
    }

    final tagName = body['tag_name'];
    final version = tagName is String ? AppVersion.tryParse(tagName) : null;
    if (version == null) {
      throw GithubReleasesException(
        'A versão publicada não segue o formato esperado: $tagName.',
      );
    }

    final installer = _selectInstaller(body['assets'], version);
    if (installer == null) {
      throw GithubReleasesException(
        'O release $tagName não possui o instalador '
        '$installerPrefix<versão>$installerExtension.',
      );
    }

    final name = installer['name'] as String;
    final url = installer['browser_download_url'] as String;
    return PublishedRelease(
      version: version,
      tagName: tagName as String,
      installerName: name,
      installerUrl: url,
    );
  }

  Map<String, dynamic>? _selectInstaller(Object? assets, AppVersion version) {
    if (assets is! List) return null;

    final expectedName = '$installerPrefix$version$installerExtension';
    final names = [
      for (final asset in assets)
        if (asset is Map<String, dynamic> &&
            asset['name'] is String &&
            asset['browser_download_url'] is String)
          asset,
    ];

    for (final asset in names) {
      if (asset['name'] == expectedName) return asset;
    }
    for (final asset in names) {
      final name = (asset['name'] as String).toLowerCase();
      if (name.startsWith(installerPrefix) && name.endsWith(installerExtension)) {
        return asset;
      }
    }
    return null;
  }
}
