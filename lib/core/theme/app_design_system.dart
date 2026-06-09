import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'app_spacing.dart';
import 'semantic_colors.dart';

/// Primary UI font family: MiSans (bundled, CJK + Latin consistent metrics).
const String kFontFamily = 'MiSans';

/// System CJK fallbacks if a glyph is missing from MiSans.
const List<String> kFontFamilyFallback = <String>[
  'Microsoft YaHei UI',
  'PingFang SC',
  'Noto Sans CJK SC',
  'Noto Sans SC',
  'Source Han Sans SC',
];

/// Typography scale: [compact] for desktop, [comfortable] for phone layouts.
enum AppTypographyScale { compact, comfortable }

/// Single entry point for Liveline visual tokens and [ThemeData] construction.
abstract final class AppDesignSystem {
  static ThemeData buildTheme(
    Brightness brightness, {
    AppTypographyScale typography = AppTypographyScale.compact,
  }) {
    final palette = SemanticPalette.forBrightness(brightness);
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.primary,
      onSecondary: palette.onPrimary,
      error: palette.priorityHigh,
      onError: palette.onPrimary,
      surface: palette.surface,
      onSurface: palette.onSurface,
      surfaceContainerHighest: palette.surfaceContainer,
      onSurfaceVariant: palette.onSurfaceVariant,
      outline: palette.outline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: kFontFamily,
      fontFamilyFallback: kFontFamilyFallback,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.surface,
      canvasColor: palette.surface,
      dividerColor: palette.outline,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: palette.surface,
        foregroundColor: palette.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: kFontFamily,
          fontFamilyFallback: kFontFamilyFallback,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: palette.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: palette.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          final compact = typography == AppTypographyScale.compact;
          return TextStyle(
            fontSize: compact ? 11 : 12,
            fontWeight: FontWeight.w600,
            letterSpacing: compact ? -0.1 : 0,
            color: selected ? palette.primary : palette.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? palette.primary : palette.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: palette.surfaceContainerLow,
        selectedIconTheme: IconThemeData(color: palette.primary, size: 24),
        unselectedIconTheme: IconThemeData(
          color: palette.onSurfaceVariant,
          size: 24,
        ),
        indicatorColor: palette.primary.withValues(alpha: 0.12),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpacing.sm,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        visualDensity: VisualDensity.standard,
      ),
      dividerTheme: DividerThemeData(color: palette.outline, thickness: 1),
      // Merge the custom styles onto the full Material 3 text theme rather than
      // replacing it: replacing would leave every style we don't override
      // (labelMedium, bodySmall, …) null, which makes Text widgets using those
      // styles fall back to an uncolored default and render invisibly on some
      // platforms. Re-apply MiSans afterwards so CJK text keeps consistent
      // metrics instead of silently falling back to the host font.
      textTheme: base.textTheme
          .merge(_textTheme(palette, typography))
          .apply(
            fontFamily: kFontFamily,
            fontFamilyFallback: kFontFamilyFallback,
          ),
    );
  }

  static TextTheme _textTheme(
    SemanticPalette palette,
    AppTypographyScale typography,
  ) {
    final compact = typography == AppTypographyScale.compact;
    final titleSpacing = compact ? -0.2 : 0.0;
    final labelSpacing = compact ? -0.1 : 0.0;

    return TextTheme(
      titleLarge: TextStyle(
        fontSize: compact ? 20 : 22,
        fontWeight: FontWeight.w700,
        letterSpacing: titleSpacing,
        color: palette.onSurface,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: compact ? 14 : 16,
        fontWeight: FontWeight.w600,
        letterSpacing: titleSpacing,
        color: palette.onSurface,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: compact ? 13 : 14,
        fontWeight: FontWeight.w600,
        letterSpacing: titleSpacing,
        color: palette.onSurface,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: compact ? 14 : 16,
        fontWeight: FontWeight.w500,
        letterSpacing: titleSpacing,
        color: palette.onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: compact ? 13 : 14,
        fontWeight: FontWeight.w500,
        letterSpacing: titleSpacing,
        color: palette.onSurfaceVariant,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: compact ? 11 : 12,
        fontWeight: FontWeight.w400,
        letterSpacing: labelSpacing,
        color: palette.onSurfaceVariant,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: compact ? 13 : 14,
        fontWeight: FontWeight.w600,
        letterSpacing: titleSpacing,
        color: palette.onSurface,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: compact ? 11 : 12,
        fontWeight: FontWeight.w500,
        letterSpacing: labelSpacing,
        color: palette.onSurfaceVariant,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: compact ? 10 : 11,
        fontWeight: FontWeight.w600,
        letterSpacing: labelSpacing,
        color: palette.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }
}
