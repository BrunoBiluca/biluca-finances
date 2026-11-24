import 'dart:io';

import 'package:biluca_financas/core/app_update/models/published_release.dart';
import 'package:biluca_financas/core/app_update/services/app_update_service.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;

class InstallerDownloadException implements Exception {
  final String message;

  const InstallerDownloadException(this.message);

  @override
  String toString() => message;
}

typedef TemporaryDirectoryProvider = Future<Directory> Function();

class InstallerDownloader {
  static const Duration defaultTimeout = Duration(minutes: 5);
  static const String updateDirectoryName = 'biluca-financas-update';

  final Client http;
  final TemporaryDirectoryProvider temporaryDirectory;
  final Duration timeout;

  const InstallerDownloader({
    required this.http,
    required this.temporaryDirectory,
    this.timeout = defaultTimeout,
  });

  Future<File> download(
    PublishedRelease release, {
    DownloadProgressCallback? onProgress,
  }) async {
    final base = await temporaryDirectory();
    final directory = Directory(p.join(base.path, updateDirectoryName));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final finalFile = File(p.join(directory.path, release.installerName));
    final partialFile = File('${finalFile.path}.part');
    if (await partialFile.exists()) await partialFile.delete();
    if (await finalFile.exists()) await finalFile.delete();

    final stopwatch = Stopwatch()..start();
    IOSink? sink;
    try {
      final request = Request('GET', Uri.parse(release.installerUrl));
      final response = await http.send(request).timeout(timeout);
      if (response.statusCode != 200) {
        throw InstallerDownloadException(
          'Falha ao baixar o instalador (HTTP ${response.statusCode}).',
        );
      }

      final contentLength = response.contentLength;
      sink = partialFile.openWrite();
      var received = 0;
      onProgress?.call(contentLength == null ? null : 0);

      await for (final chunk in response.stream.timeout(timeout)) {
        if (stopwatch.elapsed > timeout) {
          throw const InstallerDownloadException(
            'O download do instalador excedeu o tempo limite.',
          );
        }
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(_progress(received, contentLength));
      }

      await sink.flush();
      await sink.close();
      sink = null;
      await partialFile.rename(finalFile.path);
      return finalFile;
    } catch (error) {
      await sink?.close();
      if (await partialFile.exists()) await partialFile.delete();
      rethrow;
    }
  }

  double? _progress(int received, int? contentLength) {
    if (contentLength == null || contentLength <= 0) return null;
    return (received / contentLength).clamp(0.0, 1.0);
  }
}
