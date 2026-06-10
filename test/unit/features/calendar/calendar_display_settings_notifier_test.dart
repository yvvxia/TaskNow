import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/providers.dart';
import 'package:liveline/core/models/setting_keys.dart';
import 'package:liveline/features/calendar/domain/task_bar.dart';
import 'package:liveline/features/calendar/presentation/calendar_display_settings_notifier.dart';

import '../../../fakes/fake_settings_store.dart';

void main() {
  late FakeSettingsStore store;
  late ProviderContainer container;

  setUp(() {
    store = FakeSettingsStore();
    container = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
  });

  tearDown(() {
    container.dispose();
    store.dispose();
  });

  test('seeds from settings store', () {
    store = FakeSettingsStore(
      values: {
        SettingKeys.barColorMode.name: 'project',
        SettingKeys.calendarShowCompleted.name: false,
      },
    );
    final c = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(store)],
    );
    addTearDown(c.dispose);

    final state = c.read(calendarDisplaySettingsProvider);
    expect(state.colorMode, BarColorMode.project);
    expect(state.showCompleted, isFalse);
  });

  test('setShowCompleted updates state and persists', () async {
    final notifier = container.read(calendarDisplaySettingsProvider.notifier);
    notifier.setShowCompleted(false);

    expect(
      container.read(calendarDisplaySettingsProvider).showCompleted,
      isFalse,
    );
    await Future<void>.delayed(Duration.zero);
    expect(store.get(SettingKeys.calendarShowCompleted), isFalse);
  });

  test('setColorMode updates state and persists', () async {
    final notifier = container.read(calendarDisplaySettingsProvider.notifier);
    notifier.setColorMode(BarColorMode.project);

    expect(
      container.read(calendarDisplaySettingsProvider).colorMode,
      BarColorMode.project,
    );
    await Future<void>.delayed(Duration.zero);
    expect(store.get(SettingKeys.barColorMode), 'project');
  });

  test('toggle and clear project/tag filters', () {
    final notifier = container.read(calendarDisplaySettingsProvider.notifier);
    notifier.toggleProject('p1');
    notifier.toggleTag('t1');

    var state = container.read(calendarDisplaySettingsProvider);
    expect(state.projectIds, {'p1'});
    expect(state.tagIds, {'t1'});
    expect(state.hasFilters, isTrue);

    notifier.toggleProject('p1');
    state = container.read(calendarDisplaySettingsProvider);
    expect(state.projectIds, isEmpty);

    notifier.clearFilters();
    state = container.read(calendarDisplaySettingsProvider);
    expect(state.hasFilters, isFalse);
  });
}
