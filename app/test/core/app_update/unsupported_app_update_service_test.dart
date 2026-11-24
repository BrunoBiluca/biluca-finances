import 'package:biluca_financas/core/app_update/models/app_update_restart_result.dart';
import 'package:biluca_financas/core/app_update/models/app_update_status.dart';
import 'package:biluca_financas/core/app_update/models/app_version.dart';
import 'package:biluca_financas/core/app_update/services/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnsupportedAppUpdateService', () {
    const service = UnsupportedAppUpdateService(
      currentVersion: AppVersion(2, 0, 3),
    );

    test('does not support updates', () {
      expect(service.supported, isFalse);
      expect(service.currentVersion, const AppVersion(2, 0, 3));
    });

    test('does not offer an update when checking', () async {
      final status = await service.checkForUpdate();

      expect(status.state, AppUpdateState.unsupported);
      expect(status.hasUpdate, isFalse);
      expect(status.showsHomeNotification, isFalse);
      expect(status.currentVersion, const AppVersion(2, 0, 3));
    });

    test('does not download and never reports progress', () async {
      final reported = <double?>[];

      final status = await service.downloadInstaller(
        onProgress: reported.add,
      );

      expect(status.state, AppUpdateState.unsupported);
      expect(reported, isEmpty);
    });

    test('does not restart the application', () async {
      final result = await service.restartWithInstaller();

      expect(result.outcome, AppUpdateRestartOutcome.cancelled);
      expect(result.launched, isFalse);
    });
  });
}
