import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/models/app_settings.dart';
import 'package:plan_list/core/models/setting_keys.dart';
import 'package:plan_list/platform/settings/shared_prefs_settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPrefsSettingsStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('get() returns default value before init()', () {
      final store = SharedPrefsSettingsStore();
      expect(store.get(SettingKeys.themeMode), 'system');
      expect(store.get(SettingKeys.notificationsEnabled), true);
      expect(store.get(SettingKeys.defaultReminderMinutes), 15);
      expect(store.get(SettingKeys.locale), 'en');
    });

    test('after init(), get() returns default when nothing persisted', () async {
      final store = SharedPrefsSettingsStore();
      await store.init();
      expect(store.get(SettingKeys.themeMode), 'system');
      expect(store.get(SettingKeys.notificationsEnabled), true);
      expect(store.get(SettingKeys.defaultReminderMinutes), 15);
      expect(store.get(SettingKeys.locale), 'en');
    });

    test('watch() immediately emits current AppSettings', () async {
      final store = SharedPrefsSettingsStore();
      await store.init();

      final first = await store.watch().first;
      expect(first, isA<AppSettings>());
      expect(first.notificationsEnabled, true);
      expect(first.defaultReminderMinutes, 15);
      expect(first.themeMode, 'system');
      expect(first.locale, 'en');
    });

    test('set() persists value and watch() emits updated AppSettings', () async {
      final store = SharedPrefsSettingsStore();
      await store.init();

      // Collect stream values
      final emitted = <AppSettings>[];
      final sub = store.watch().listen(emitted.add);

      await store.set(SettingKeys.themeMode, 'dark');
      await store.set(SettingKeys.notificationsEnabled, false);

      sub.cancel();

      // First emission is the current state; subsequent ones are updates
      expect(emitted.length, greaterThanOrEqualTo(2));
      expect(emitted.last.themeMode, 'dark');
      expect(emitted.last.notificationsEnabled, false);
    });

    test('set() persists value across store instances (via SharedPrefs)', () async {
      SharedPreferences.setMockInitialValues({});

      final store1 = SharedPrefsSettingsStore();
      await store1.init();
      await store1.set(SettingKeys.themeMode, 'light');

      // Second instance reads from the same SharedPreferences mock
      final store2 = SharedPrefsSettingsStore();
      await store2.init();
      expect(store2.get(SettingKeys.themeMode), 'light');
    });

    test('watch() emits AppSettings with updated fields after set()', () async {
      final store = SharedPrefsSettingsStore();
      await store.init();

      await store.set(SettingKeys.locale, 'zh');
      final settings = await store.watch().first;
      expect(settings.locale, 'zh');
    });

    test('extended keys (overdueRepeatHours, dndEnabled) persist via get/set',
        () async {
      final store = SharedPrefsSettingsStore();
      await store.init();

      expect(store.get(SettingKeys.overdueRepeatHours), 24);
      await store.set(SettingKeys.overdueRepeatHours, 12);
      expect(store.get(SettingKeys.overdueRepeatHours), 12);

      expect(store.get(SettingKeys.dndEnabled), false);
      await store.set(SettingKeys.dndEnabled, true);
      expect(store.get(SettingKeys.dndEnabled), true);
    });
  });
}
