import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppVersion', () {
    test('parses major, minor and patch', () {
      final version = AppVersion.parse('2.1.3');

      expect(version.major, 2);
      expect(version.minor, 1);
      expect(version.patch, 3);
      expect(version.toString(), '2.1.3');
    });

    test('ignores the v prefix', () {
      expect(AppVersion.parse('v2.1.0'), const AppVersion(2, 1, 0));
      expect(AppVersion.parse('V2.1.0'), const AppVersion(2, 1, 0));
    });

    test('ignores pre-release and build suffixes', () {
      expect(AppVersion.parse('2.1.0-beta.2'), const AppVersion(2, 1, 0));
      expect(AppVersion.parse('2.1.0+1'), const AppVersion(2, 1, 0));
    });

    test('detects a newer major version', () {
      expect(
        const AppVersion(3, 0, 0).isNewerThan(const AppVersion(2, 9, 9)),
        isTrue,
      );
    });

    test('detects a newer minor version', () {
      expect(
        const AppVersion(2, 2, 0).isNewerThan(const AppVersion(2, 1, 9)),
        isTrue,
      );
    });

    test('detects a newer patch version', () {
      expect(
        const AppVersion(2, 1, 4).isNewerThan(const AppVersion(2, 1, 3)),
        isTrue,
      );
    });

    test('does not consider the same version as newer', () {
      expect(
        const AppVersion(2, 1, 3).isNewerThan(const AppVersion(2, 1, 3)),
        isFalse,
      );
    });

    test('does not consider an older version as newer', () {
      expect(
        const AppVersion(2, 1, 3).isNewerThan(const AppVersion(2, 2, 0)),
        isFalse,
      );
    });

    test('rejects an unrecognized version', () {
      expect(AppVersion.tryParse('latest'), isNull);
      expect(AppVersion.tryParse('2.1'), isNull);
      expect(AppVersion.tryParse('2.1.x'), isNull);
      expect(() => AppVersion.parse('release-2.1.3'),
          throwsA(isA<FormatException>()));
    });
  });
}
