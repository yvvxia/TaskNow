import 'package:flutter/material.dart';

import '../../core/enums/enums.dart';

/// Brightness-aware semantic palette (design-style §配色方案).
class SemanticPalette {
  const SemanticPalette({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.outline,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.priorityHigh,
    required this.priorityMedium,
    required this.priorityLow,
    required this.complete,
    required this.overdue,
    required this.overdueOn,
  });

  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color outline;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color priorityHigh;
  final Color priorityMedium;
  final Color priorityLow;
  final Color complete;
  final Color overdue;
  final Color overdueOn;

  static const SemanticPalette light = SemanticPalette(
    primary: Color(0xFF2563EB),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF8FAFC),
    surfaceContainer: Color(0xFFF1F5F9),
    outline: Color(0xFFE2E8F0),
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF64748B),
    priorityHigh: Color(0xFFDC2626),
    priorityMedium: Color(0xFFD97706),
    priorityLow: Color(0xFF16A34A),
    complete: Color(0xFF94A3B8),
    overdue: Color(0xFFFEE2E2),
    overdueOn: Color(0xFFB91C1C),
  );

  static const SemanticPalette dark = SemanticPalette(
    primary: Color(0xFF3B82F6),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFF121212),
    surfaceContainerLow: Color(0xFF1E1E1E),
    surfaceContainer: Color(0xFF2C2C2C),
    outline: Color(0xFF3F3F3F),
    onSurface: Color(0xFFF1F5F9),
    onSurfaceVariant: Color(0xFF94A3B8),
    priorityHigh: Color(0xFFEF4444),
    priorityMedium: Color(0xFFF59E0B),
    priorityLow: Color(0xFF22C55E),
    complete: Color(0xFF64748B),
    overdue: Color(0xFF3F1F1F),
    overdueOn: Color(0xFFFCA5A5),
  );

  static SemanticPalette forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Semantic color accessors shared across features.
abstract final class SemanticColors {
  static const Color primary = Color(0xFF2563EB);

  static SemanticPalette paletteOf(BuildContext context) {
    return SemanticPalette.forBrightness(Theme.of(context).brightness);
  }

  static Color colorForPriority(
    Priority priority, {
    Brightness brightness = Brightness.light,
  }) {
    final p = SemanticPalette.forBrightness(brightness);
    switch (priority) {
      case Priority.high:
        return p.priorityHigh;
      case Priority.medium:
        return p.priorityMedium;
      case Priority.low:
        return p.priorityLow;
    }
  }

  /// Light-tinted badge background for [priority] at 12% opacity.
  static Color badgeBackgroundForPriority(
    Priority priority, {
    Brightness brightness = Brightness.light,
  }) {
    return colorForPriority(
      priority,
      brightness: brightness,
    ).withValues(alpha: 0.12);
  }
}
