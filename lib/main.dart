import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/providers.dart';
import 'data/data_providers.dart';
import 'data/db/app_database.dart';
import 'features/notification/application/notification_action_handler.dart';
import 'features/notification/notification_providers.dart';
import 'platform/notifications/notification_service_factory.dart';
import 'platform/settings/shared_prefs_settings_store.dart';
import 'platform/sync/no_op_sync_engine.dart';

/// Application entry point + dependency-injection wiring.
///
/// Assembles the concrete implementations (Drift database, settings store,
/// platform notifications, sync no-op) and injects them onto the abstract
/// `core/contracts` providers via [ProviderScope.overrides], following the
/// dependency-inversion seam described in `design/00-architecture-overview.md`
/// §8.
///
/// Side effects are kept resilient so the app still boots when a platform
/// plugin is unavailable: under `flutter test` the blocking
/// `SharedPreferences.getInstance()` is skipped (the store transparently falls
/// back to defaults), and notification/database initialization is performed
/// lazily and guarded by [NotificationBootstrap].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // MiSans IP License requires the app to state that MiSans Fonts are used.
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      <String>['MiSans'],
      'This application uses MiSans Fonts.\n\n'
      'MiSans © Xiaomi Inc. — a global free commercial-use font, licensed '
      'under the MiSans Fonts Intellectual Property License Agreement. The '
      'font files are bundled unmodified and are not redistributed separately. '
      'See https://hyperos.mi.com/font/ for the full agreement.',
    );
  });

  // Data layer — LazyDatabase defers the file/path lookup to first query.
  final AppDatabase db = AppDatabase(openConnection());

  // Settings — load persisted values. Skipped under the test harness, where the
  // SharedPreferences platform channel is unavailable and would never resolve.
  final settings = SharedPrefsSettingsStore();
  if (!_isRunningUnderTest) {
    await settings.init();
  }

  // Platform notifications — concrete service is initialized later by
  // [NotificationBootstrap] (post-frame, guarded).
  final notif = createPlatformNotificationService();

  runApp(
    ProviderScope(
      overrides: [
        ...driftDataLayerOverrides(db),
        settingsStoreProvider.overrideWithValue(settings),
        notificationServiceProvider.overrideWithValue(notif),
        syncEngineProvider.overrideWithValue(const NoOpSyncEngine()),
        routerProvider.overrideWithValue(appRouter),
      ],
      child: const NotificationBootstrap(child: LivelineApp()),
    ),
  );
}

/// `true` when executed by the Flutter test harness, which sets the
/// `FLUTTER_TEST` environment variable.
final bool _isRunningUnderTest = Platform.environment.containsKey(
  'FLUTTER_TEST',
);
