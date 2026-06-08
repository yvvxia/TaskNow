import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Friendly empty state when search returns no tasks.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // Centered when there is room, but scrollable so it can never overflow
    // (e.g. very short windows or transient layout frames during navigation).
    return LayoutBuilder(
      key: const Key('search-empty-state'),
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
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message ?? l10n?.searchNoResults ??
                        'No tasks match your search',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n?.searchTryDifferentFilters ??
                        'Try different keywords or filters',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
