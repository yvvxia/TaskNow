import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/models/setting_key.dart';
import '../../../core/models/setting_keys.dart';
import '../domain/calendar_display_settings.dart';
import '../domain/task_bar.dart';

/// Holds the live [CalendarDisplaySettings] for the calendar views.
///
/// Durable fields ([CalendarDisplaySettings.showCompleted] and
/// [CalendarDisplaySettings.colorMode]) are seeded from and written back to the
/// settings store; the list/tag filters are session state.
final calendarDisplaySettingsProvider =
    NotifierProvider<CalendarDisplaySettingsNotifier, CalendarDisplaySettings>(
      CalendarDisplaySettingsNotifier.new,
    );

class CalendarDisplaySettingsNotifier
    extends Notifier<CalendarDisplaySettings> {
  @override
  CalendarDisplaySettings build() {
    var colorMode = BarColorMode.priority;
    var showCompleted = true;
    try {
      final store = ref.read(settingsStoreProvider);
      colorMode = store.get(SettingKeys.barColorMode) == 'project'
          ? BarColorMode.project
          : BarColorMode.priority;
      showCompleted = store.get(SettingKeys.calendarShowCompleted);
    } catch (_) {
      // Store not available (e.g. tests without an override) → defaults.
    }
    return CalendarDisplaySettings(
      showCompleted: showCompleted,
      colorMode: colorMode,
    );
  }

  void setShowCompleted(bool value) {
    state = state.copyWith(showCompleted: value);
    _persist(SettingKeys.calendarShowCompleted, value);
  }

  void setColorMode(BarColorMode mode) {
    state = state.copyWith(colorMode: mode);
    _persist(
      SettingKeys.barColorMode,
      mode == BarColorMode.project ? 'project' : 'priority',
    );
  }

  void toggleProject(String projectId) {
    final next = Set<String>.from(state.projectIds);
    if (!next.remove(projectId)) next.add(projectId);
    state = state.copyWith(projectIds: next);
  }

  void toggleTag(String tagId) {
    final next = Set<String>.from(state.tagIds);
    if (!next.remove(tagId)) next.add(tagId);
    state = state.copyWith(tagIds: next);
  }

  void clearFilters() {
    state = state.copyWith(projectIds: const {}, tagIds: const {});
  }

  Future<void> _persist<T>(SettingKey<T> key, T value) async {
    try {
      await ref.read(settingsStoreProvider).set(key, value);
    } catch (_) {
      // Best-effort persistence; ignore when no store is available.
    }
  }
}
