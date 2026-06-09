/// Layout and spacing tokens (design-style §形状与间距).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Minimum height for a task list row (comfortable density).
  static const double taskRowMinHeight = 56;

  /// Desktop sidebar expanded width.
  static const double sidebarWidth = 240;

  /// Desktop sidebar collapsed (icon-only) width.
  static const double sidebarCollapsedWidth = 72;

  /// Right detail panel width on expanded desktop.
  static const double detailPanelWidth = 320;

  /// Max height for desktop search popup.
  static const double searchPopupMaxHeight = 480;
}
