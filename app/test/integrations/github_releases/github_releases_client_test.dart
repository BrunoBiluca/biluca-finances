import 'dart:convert';

import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:biluca_financas/integrations/github_releases/github_releases_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

void main() {
  const latestReleaseUrl =
      'https://api.github.com/repos/BrunoBiluca/biluca-finances/releases/latest';

  Map<String, dynamic> releaseBody({
    String tagName = '2.1.0',
    List<Map<String, dynamic>>? assets,
  }) {
    return {
      'tag_name': tagName,
      'assets': assets ??
          [
            {
              'name': 'biluca-financas-setup-2.1.0.exe',
              'browser_download_url':
                  'https://github.com/BrunoBiluca/biluca-finances/releases/download/2.1.0/biluca-financas-setup-2.1.0.exe',
            },
          ],
    };
  }

  GithubReleasesClient clientReturning(
    Object body, {
    int statusCode = 200,
    void Function(Request request)? onRequest,
  }) {
    return GithubReleasesClient(
      http: MockClient((request) async {
        onRequest?.call(request);
        return Response(
          body is String ? body : jsonEncode(body),
          statusCode,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
  }

  test('reads the latest published version and the expected installer', () async {
    final release = await clientReturning(releaseBody()).fetchLatestRelease();

    expect(release.version, const AppVersion(2, 1, 0));
    expect(release.tagName, '2.1.0');
    expect(release.installerName, 'biluca-financas-setup-2.1.0.exe');
    expect(release.installerUrl, endsWith('biluca-financas-setup-2.1.0.exe'));
  });

  test('sends the headers required by the GitHub API', () async {
    Request? sent;
    await clientReturning(releaseBody(), onRequest: (request) => sent = request)
        .fetchLatestRelease();

    expect(sent!.url.toString(), latestReleaseUrl);
    expect(sent!.headers['Accept'], 'application/vnd.github+json');
    expect(sent!.headers['X-GitHub-Api-Version'], '2022-11-28');
    expect(sent!.headers['User-Agent'], isNotEmpty);
  });

  test('accepts an installer with the expected prefix', () async {
    final release = await clientReturning(releaseBody(
      tagName: 'v2.1.0',
      assets: [
        {
          'name': 'source-code.zip',
          'browser_download_url': 'https://example.com/source-code.zip',
        },
        {
          'name': 'biluca-financas-setup-2.1.0-x64.exe',
          'browser_download_url': 'https://example.com/x64.exe',
        },
      ],
    )).fetchLatestRelease();

    expect(release.version, const AppVersion(2, 1, 0));
    expect(release.installerName, 'biluca-financas-setup-2.1.0-x64.exe');
  });

  test('fails when the release has no installer', () async {
    final client = clientReturning(releaseBody(
      assets: [
        {
          'name': 'source-code.zip',
          'browser_download_url': 'https://example.com/source-code.zip',
        },
      ],
    ));

    await expectLater(
      client.fetchLatestRelease(),
      throwsA(isA<GithubReleasesException>().having(
        (error) => error.message,
        'message',
        contains('não possui o instalador'),
      )),
    );
  });

  test('fails when no release is published', () async {
    final client = clientReturning(
      jsonEncode({'message': 'Not Found'}),
      statusCode: 404,
    );

    await expectLater(
      client.fetchLatestRelease(),
      throwsA(isA<GithubReleasesException>().having(
        (error) => error.message,
        'message',
        contains('Nenhuma versão publicada'),
      )),
    );
  });

  test('fails when the request limit is reached', () async {
    final client = clientReturning(
      jsonEncode({'message': 'API rate limit exceeded'}),
      statusCode: 403,
    );

    await expectLater(
      client.fetchLatestRelease(),
      throwsA(isA<GithubReleasesException>().having(
        (error) => error.message,
        'message',
        contains('limite de consultas'),
      )),
    );
  });

  test('fails when the published version is not recognized', () async {
    final client = clientReturning(releaseBody(tagName: 'release-latest'));

    await expectLater(
      client.fetchLatestRelease(),
      throwsA(isA<GithubReleasesException>().having(
        (error) => error.message,
        'message',
        contains('não segue o formato esperado'),
      )),
    );
  });
}

