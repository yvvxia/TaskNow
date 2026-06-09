import 'package:flutter/material.dart';

/// Friendly empty-state block: a centered illustration above a title and an
/// optional subtitle. Scrollable so it never overflows in short viewports.
///
/// The bundled illustrations use transparent backgrounds, so the same asset
/// works in both light and dark themes.
class EmptyIllustration extends StatelessWidget {
  const EmptyIllustration({
    super.key,
    required this.asset,
    required this.title,
    this.subtitle,
    this.maxImageSize = 200,
  });

  /// Asset path of the illustration (e.g. `assets/illustrations/empty_tasks.png`).
  final String asset;

  /// Primary message (e.g. "No tasks today").
  final String title;

  /// Optional supporting line below the title.
  final String? subtitle;

  /// Upper bound for the illustration's width/height in logical pixels.
  final double maxImageSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 0,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxImageSize,
                      maxHeight: maxImageSize,
                    ),
                    child: Image.asset(
                      asset,
                      fit: BoxFit.contain,
                      // Keep layout stable if the asset is missing.
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
