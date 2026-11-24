import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:biluca_financas/core/app_update/models/published_release.dart';
import 'package:biluca_financas/integrations/app_update/installer_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;

void main() {
  const release = PublishedRelease(
    version: AppVersion(2, 1, 0),
    tagName: '2.1.0',
    installerName: 'biluca-financas-setup-2.1.0.exe',
    installerUrl: 'https://example.com/biluca-financas-setup-2.1.0.exe',
  );
  const content = 'conteudo-do-instalador';

  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('update-test');
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  InstallerDownloader downloaderFor(
    StreamedResponse Function(BaseRequest request) responseFactory,
  ) {
    return InstallerDownloader(
      http: MockClient.streaming(
        (request, bodyStream) async => responseFactory(request),
      ),
      temporaryDirectory: () async => temporaryDirectory,
    );
  }

  File finalFile() => File(p.join(
        temporaryDirectory.path,
        InstallerDownloader.updateDirectoryName,
        release.installerName,
      ));

  test('stores the installer with its final name only after completing',
      () async {
    final bytes = utf8.encode(content);
    final progress = <double?>[];
    final downloader = downloaderFor(
      (_) => StreamedResponse(
        Stream.fromIterable([bytes.sublist(0, 5), bytes.sublist(5)]),
        200,
        contentLength: bytes.length,
      ),
    );

    final file = await downloader.download(release, onProgress: progress.add);

    expect(file.path, finalFile().path);
    expect(await file.exists(), isTrue);
    expect(await File('${file.path}.part').exists(), isFalse);
    expect(await file.readAsString(), content);
    expect(progress.first, 0);
    expect(progress.last, 1.0);
    expect(progress.length, greaterThan(2));
  });

  test('reports an unknown progress when the size is not provided', () async {
    final bytes = utf8.encode(content);
    final progress = <double?>[];
    final downloader = downloaderFor(
      (_) => StreamedResponse(Stream.fromIterable([bytes]), 200),
    );

    await downloader.download(release, onProgress: progress.add);

    expect(progress, everyElement(isNull));
  });

  test('discards the partial file when the download fails', () async {
    final bytes = utf8.encode(content);
    final controller = StreamController<List<int>>();
    final downloader = downloaderFor((_) {
      controller.add(bytes.sublist(0, 4));
      controller.addError(const SocketException('conexão interrompida'));
      controller.close();
      return StreamedResponse(controller.stream, 200, contentLength: 100);
    });

    await expectLater(
      downloader.download(release),
      throwsA(isA<SocketException>()),
    );

    expect(await finalFile().exists(), isFalse);
    expect(await File('${finalFile().path}.part').exists(), isFalse);
  });

  test('rejects a download that does not return the installer', () async {
    final downloader = downloaderFor(
      (_) => StreamedResponse(const Stream.empty(), 404),
    );

    await expectLater(
      downloader.download(release),
      throwsA(isA<InstallerDownloadException>().having(
        (error) => error.message,
        'message',
        contains('HTTP 404'),
      )),
    );

    expect(await finalFile().exists(), isFalse);
  });
}
