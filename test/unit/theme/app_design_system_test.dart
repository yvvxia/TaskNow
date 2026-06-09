import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/theme/app_design_system.dart';

void main() {
  group('AppDesignSystem.buildTheme text theme', () {
    for (final brightness in Brightness.values) {
      test('exposes every core text style with a color ($brightness)', () {
        final textTheme = AppDesignSystem.buildTheme(brightness).textTheme;

        // Styles consumed across the app (e.g. add-task sheet labels use
        // labelMedium, empty states use bodySmall). A null style makes Text
        // fall back to an uncolored default and renders invisibly on Android.
        final styles = <String, TextStyle?>{
          'titleLarge': textTheme.titleLarge,
          'titleMedium': textTheme.titleMedium,
          'bodyLarge': textTheme.bodyLarge,
          'bodyMedium': textTheme.bodyMedium,
          'bodySmall': textTheme.bodySmall,
          'labelLarge': textTheme.labelLarge,
          'labelMedium': textTheme.labelMedium,
          'labelSmall': textTheme.labelSmall,
        };

        styles.forEach((name, style) {
          expect(style, isNotNull, reason: '$name should not be null');
          expect(style!.color, isNotNull, reason: '$name should have a color');
          expect(style.fontFamily, 'MiSans', reason: '$name should use MiSans');
        });
      });
    }
  });

  group('AppTypographyScale', () {
    test('comfortable scale uses larger body text than compact', () {
      final compact = AppDesignSystem.buildTheme(
        Brightness.light,
        typography: AppTypographyScale.compact,
      ).textTheme;
      final comfortable = AppDesignSystem.buildTheme(
        Brightness.light,
        typography: AppTypographyScale.comfortable,
      ).textTheme;

      expect(
        comfortable.bodyMedium!.fontSize,
        greaterThan(compact.bodyMedium!.fontSize!),
      );
      expect(
        comfortable.titleMedium!.fontSize,
        greaterThan(compact.titleMedium!.fontSize!),
      );
      expect(
        comfortable.labelSmall!.fontSize,
        greaterThan(compact.labelSmall!.fontSize!),
      );
    });

    test('compact scale tightens letter spacing', () {
      final compact = AppDesignSystem.buildTheme(
        Brightness.light,
        typography: AppTypographyScale.compact,
      ).textTheme;
      final comfortable = AppDesignSystem.buildTheme(
        Brightness.light,
        typography: AppTypographyScale.comfortable,
      ).textTheme;

      expect(compact.bodyMedium!.letterSpacing, lessThan(0));
      expect(comfortable.bodyMedium!.letterSpacing, 0);
    });
  });
}
