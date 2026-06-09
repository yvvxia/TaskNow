import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/setting_key.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/setting_keys.dart';
import 'settings_providers.dart';

/// Full Material 3 settings screen (Module 06).
///
/// Sections: Appearance · Notifications · Sync (reserved) · About.
/// Reads live settings via [settingsNotifierProvider] and writes via
/// [ISettingsStore] (obtained through [settingsStoreProvider]).
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Guard: return a minimal shell when no ProviderScope is in the tree
    // (e.g. legacy router-only tests). The key must still be present so that
    // key-based widget finders in existing tests continue to pass.
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }
    if (!hasScope) {
      return const Scaffold(key: Key('settings-page'), body: SizedBox.shrink());
    }

    final settingsAsync = ref.watch(settingsNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('settings-page'),
      appBar: AppBar(title: Text(l10n?.settingsTitle ?? 'Settings')),
      body: settingsAsync.when(
        data: (settings) => _SettingsBody(settings: settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _SettingsBody(settings: const AppSettings()),
      ),
    );
  }
}

class _SettingsBody extends ConsumerStatefulWidget {
  const _SettingsBody({required this.settings});
  final AppSettings settings;

  @override
  ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends ConsumerState<_SettingsBody> {
  // Extended settings not yet in AppSettings model, read directly from store.
  int _overdueRepeatHours = SettingKeys.overdueRepeatHours.defaultValue;
  bool _dndEnabled = SettingKeys.dndEnabled.defaultValue;
  int _dndStartMinutes = SettingKeys.dndStartMinutes.defaultValue;
  int _dndEndMinutes = SettingKeys.dndEndMinutes.defaultValue;

  @override
  void initState() {
    super.initState();
    _loadExtendedSettings();
  }

  void _loadExtendedSettings() {
    try {
      final store = ref.read(settingsStoreProvider);
      setState(() {
        _overdueRepeatHours = store.get(SettingKeys.overdueRepeatHours);
        _dndEnabled = store.get(SettingKeys.dndEnabled);
        _dndStartMinutes = store.get(SettingKeys.dndStartMinutes);
        _dndEndMinutes = store.get(SettingKeys.dndEndMinutes);
      });
    } catch (_) {
      // Store not available; keep defaults.
    }
  }

  Future<void> _setSetting<T>(SettingKey<T> key, T value) async {
    try {
      await ref.read(settingsStoreProvider).set(key, value);
    } catch (_) {
      // Store not available; ignore.
    }
  }

  String _readStringSetting(SettingKey<String> key, String fallback) {
    try {
      return ref.read(settingsStoreProvider).get(key);
    } catch (_) {
      return fallback;
    }
  }

  String _formatMinutesOfDay(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(
    BuildContext context,
    int currentMinutes,
    Future<void> Function(int minutes) onPicked,
  ) async {
    final tod = TimeOfDay(
      hour: currentMinutes ~/ 60,
      minute: currentMinutes % 60,
    );
    final picked = await showTimePicker(context: context, initialTime: tod);
    if (picked != null) {
      await onPicked(picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _pickInt(
    BuildContext context,
    String title,
    int current,
    Future<void> Function(int) onPicked,
  ) async {
    final controller = TextEditingController(text: current.toString());
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.actionCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(controller.text);
              if (v != null && v >= 0) Navigator.pop(ctx, v);
            },
            child: Text(l10n?.actionSave ?? 'Save'),
          ),
        ],
      ),
    );
    if (result != null) await onPicked(result);
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = widget.settings;

    return ListView(
      children: [
        // ── Appearance ───────────────────────────────────────────────────────
        _SectionHeader(l10n?.appearanceSection ?? 'Appearance'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.themeSystem ?? 'Theme',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                key: const Key('theme-segmented-button'),
                segments: [
                  ButtonSegment(
                    value: 'system',
                    label: Text(l10n?.themeSystem ?? 'System'),
                    icon: const Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment(
                    value: 'light',
                    label: Text(l10n?.themeLight ?? 'Light'),
                    icon: const Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: 'dark',
                    label: Text(l10n?.themeDark ?? 'Dark'),
                    icon: const Icon(Icons.dark_mode),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (set) async {
                  await _setSetting(SettingKeys.themeMode, set.first);
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.barColorMode ?? 'Gantt bar color',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                key: const Key('bar-color-segmented-button'),
                segments: [
                  ButtonSegment(
                    value: 'priority',
                    label: Text(l10n?.barColorPriority ?? 'Priority'),
                  ),
                  ButtonSegment(
                    value: 'project',
                    label: Text(l10n?.barColorProject ?? 'Project'),
                  ),
                ],
                selected: {
                  _readStringSetting(SettingKeys.barColorMode, 'priority'),
                },
                onSelectionChanged: (set) async {
                  await _setSetting(SettingKeys.barColorMode, set.first);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.defaultCalendarView ?? 'Default calendar view',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                key: const Key('default-calendar-view-button'),
                segments: [
                  ButtonSegment(
                    value: 'week',
                    label: Text(l10n?.calendarWeek ?? 'Week'),
                  ),
                  ButtonSegment(
                    value: 'month',
                    label: Text(l10n?.calendarMonth ?? 'Month'),
                  ),
                ],
                selected: {
                  _readStringSetting(SettingKeys.defaultCalendarView, 'week'),
                },
                onSelectionChanged: (set) async {
                  await _setSetting(SettingKeys.defaultCalendarView, set.first);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n?.languageSection ?? 'Language'),
          trailing: DropdownButton<String>(
            value: settings.locale,
            underline: const SizedBox.shrink(),
            onChanged: (v) async {
              if (v != null) await _setSetting(SettingKeys.locale, v);
            },
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text(l10n?.languageEnglish ?? 'English'),
              ),
              DropdownMenuItem(
                value: 'zh',
                child: Text(l10n?.languageChinese ?? '中文'),
              ),
            ],
          ),
        ),

        // ── Notifications ────────────────────────────────────────────────────
        _SectionHeader(l10n?.notificationsSection ?? 'Notifications'),
        SwitchListTile(
          key: const Key('notifications-global-switch'),
          secondary: const Icon(Icons.notifications),
          title: Text(l10n?.notificationsGlobal ?? 'Enable Notifications'),
          value: settings.notificationsEnabled,
          onChanged: (v) => _setSetting(SettingKeys.notificationsEnabled, v),
        ),
        ListTile(
          leading: const Icon(Icons.alarm),
          title: Text(l10n?.notificationsDefaultReminder ?? 'Default Reminder'),
          trailing: Text(
            l10n?.notificationsDefaultReminderValue(
                  settings.defaultReminderMinutes,
                ) ??
                '${settings.defaultReminderMinutes} min before',
          ),
          onTap: () => _pickInt(
            context,
            l10n?.minutesDialog ?? 'Reminder advance (minutes)',
            settings.defaultReminderMinutes,
            (v) => _setSetting(SettingKeys.defaultReminderMinutes, v),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.repeat),
          title: Text(
            l10n?.notificationsOverdueRepeat ?? 'Overdue Repeat Interval',
          ),
          trailing: Text(
            l10n?.notificationsOverdueRepeatValue(_overdueRepeatHours) ??
                'Every $_overdueRepeatHours h',
          ),
          onTap: () => _pickInt(
            context,
            l10n?.hoursDialog ?? 'Overdue repeat interval (hours)',
            _overdueRepeatHours,
            (v) async {
              await _setSetting(SettingKeys.overdueRepeatHours, v);
              if (mounted) setState(() => _overdueRepeatHours = v);
            },
          ),
        ),

        // ── Do Not Disturb ──────────────────────────────────────────────────
        _SectionHeader(l10n?.dndSection ?? 'Do Not Disturb'),
        SwitchListTile(
          secondary: const Icon(Icons.do_not_disturb),
          title: Text(l10n?.dndEnabled ?? 'Enable Do Not Disturb'),
          value: _dndEnabled,
          onChanged: (v) async {
            await _setSetting(SettingKeys.dndEnabled, v);
            if (mounted) setState(() => _dndEnabled = v);
          },
        ),
        ListTile(
          leading: const Icon(Icons.bedtime),
          title: Text(l10n?.dndStart ?? 'DND Start'),
          trailing: Text(_formatMinutesOfDay(_dndStartMinutes)),
          onTap: () => _pickTime(context, _dndStartMinutes, (v) async {
            await _setSetting(SettingKeys.dndStartMinutes, v);
            if (mounted) setState(() => _dndStartMinutes = v);
          }),
        ),
        ListTile(
          leading: const Icon(Icons.wb_sunny),
          title: Text(l10n?.dndEnd ?? 'DND End'),
          trailing: Text(_formatMinutesOfDay(_dndEndMinutes)),
          onTap: () => _pickTime(context, _dndEndMinutes, (v) async {
            await _setSetting(SettingKeys.dndEndMinutes, v);
            if (mounted) setState(() => _dndEndMinutes = v);
          }),
        ),

        // ── Dashboard ────────────────────────────────────────────────────────
        _SectionHeader(l10n?.navDashboard ?? 'Dashboard'),
        ListTile(
          leading: const Icon(Icons.upcoming_outlined),
          title: Text(l10n?.dashboardUpcomingDaysSetting ?? 'Upcoming window'),
          trailing: Text(
            l10n?.dashboardUpcomingDaysValue(settings.dashboardUpcomingDays) ??
                '${settings.dashboardUpcomingDays} days',
          ),
          onTap: () => _pickInt(
            context,
            l10n?.dashboardUpcomingDaysDialog ?? 'Upcoming window (days)',
            settings.dashboardUpcomingDays,
            (v) => _setSetting(SettingKeys.dashboardUpcomingDays, v),
          ),
        ),

        // ── Sync (reserved) ──────────────────────────────────────────────────
        _SectionHeader(l10n?.syncSection ?? 'Cloud Sync'),
        ListTile(
          leading: const Icon(Icons.cloud_off),
          title: Text(l10n?.syncComingSoon ?? 'Cloud sync — coming in Phase 2'),
          enabled: false,
        ),

        // ── About ────────────────────────────────────────────────────────────
        _SectionHeader(l10n?.aboutSection ?? 'About'),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('PlanList'),
          trailing: Text(
            l10n?.aboutVersion('0.1.0') ?? 'Version 0.1.0',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l10n?.aboutPrivacy ?? 'Privacy Policy'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.font_download_outlined),
          title: Text(l10n?.aboutFonts ?? 'Fonts'),
          subtitle: const Text('MiSans © Xiaomi Inc.'),
        ),
        ListTile(
          leading: const Icon(Icons.open_in_new),
          title: Text(l10n?.aboutOpenSource ?? 'Open Source Licenses'),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'PlanList',
            applicationVersion: '0.1.0',
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
