import 'task_bar.dart';

/// User-controlled display options for the calendar views: which tasks are
/// shown (completed toggle, project/tag filters) and how bars are colored.
///
/// Pure value object owned by the domain layer; the presentation notifier
/// persists the durable fields ([showCompleted], [colorMode]) via the settings
/// store and feeds the rest into the visible-bar query.
class CalendarDisplaySettings {
  const CalendarDisplaySettings({
    this.showCompleted = true,
    this.colorMode = BarColorMode.priority,
    this.projectIds = const <String>{},
    this.tagIds = const <String>{},
  });

  /// When false, completed tasks are excluded from the calendar.
  final bool showCompleted;

  /// Bar coloring strategy (priority vs. project hue).
  final BarColorMode colorMode;

  /// When non-empty, only tasks in these projects are shown.
  final Set<String> projectIds;

  /// When non-empty, only tasks carrying one of these tags are shown.
  final Set<String> tagIds;

  /// True when any list/tag filter is active.
  bool get hasFilters => projectIds.isNotEmpty || tagIds.isNotEmpty;

  CalendarDisplaySettings copyWith({
    bool? showCompleted,
    BarColorMode? colorMode,
    Set<String>? projectIds,
    Set<String>? tagIds,
  }) {
    return CalendarDisplaySettings(
      showCompleted: showCompleted ?? this.showCompleted,
      colorMode: colorMode ?? this.colorMode,
      projectIds: projectIds ?? this.projectIds,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarDisplaySettings &&
        other.showCompleted == showCompleted &&
        other.colorMode == colorMode &&
        _setEquals(other.projectIds, projectIds) &&
        _setEquals(other.tagIds, tagIds);
  }

  @override
  int get hashCode => Object.hash(
    showCompleted,
    colorMode,
    Object.hashAllUnordered(projectIds),
    Object.hashAllUnordered(tagIds),
  );

  static bool _setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}
