import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../search_controller.dart' as app_search;
import '../search_providers.dart';
import 'empty_state.dart';
import 'filter_chips_row.dart';
import 'result_list.dart';

/// Sentinel route value for the search overlay destination (not a real page).
const String kSearchOverlayRoute = '__search__';

/// Width above which the search popup is capped and centered (desktop). Mirrors
/// `kExpandedBreakpoint` in the adaptive shell; kept local to avoid an import
/// cycle with `adaptive_scaffold.dart`.
const double _kDesktopBreakpoint = 1024;

/// Capped popup width used on desktop so the search box doesn't stretch across
/// a wide window.
const double _kDesktopSearchWidth = 600;

/// Global search overlay driven by [ui.SearchController.openView]. The anchor
/// bar is hidden; navigation items call [openSearchOverlay] instead.
class AppSearchOverlay extends ConsumerStatefulWidget {
  const AppSearchOverlay({
    super.key,
    required this.searchController,
    required this.child,
  });

  final SearchController searchController;
  final Widget child;

  @override
  ConsumerState<AppSearchOverlay> createState() => _AppSearchOverlayState();
}

class _AppSearchOverlayState extends ConsumerState<AppSearchOverlay> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    // Status-bar / notch inset so the popup opens below it on mobile (0 on
    // desktop). The popup anchors to this hidden box's top-left.
    final topInset = media.padding.top;
    final isDesktop = screenWidth > _kDesktopBreakpoint;
    final anchorWidth = isDesktop
        ? _kDesktopSearchWidth
        : screenWidth;
    // Center the capped box on desktop; flush-left (full width) otherwise.
    final leftOffset = isDesktop ? (screenWidth - _kDesktopSearchWidth) / 2 : 0.0;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: leftOffset,
          top: topInset,
          child: SearchAnchor(
            key: const Key('search-overlay'),
            searchController: widget.searchController,
            isFullScreen: false,
            viewConstraints: BoxConstraints(maxWidth: anchorWidth, maxHeight: 480),
            viewOnOpen: () {
              ref
                  .read(app_search.searchControllerProvider.notifier)
                  .setKeyword(widget.searchController.text);
            },
            viewOnChanged: (value) {
              ref
                  .read(app_search.searchControllerProvider.notifier)
                  .setKeyword(value);
            },
            // Invisible anchor whose width/position drive the popup's
            // width/position. Height 0 keeps it visually hidden.
            builder: (context, controller) =>
                SizedBox(width: anchorWidth, height: 0),
            suggestionsBuilder: (context, controller) {
              return [
                _SearchOverlayPanel(
                  onTaskTap: (taskId) {
                    controller.closeView(controller.text);
                    if (context.mounted) {
                      context.go('/task/$taskId');
                    }
                  },
                ),
              ];
            },
            viewBuilder: (suggestions) {
              final list = suggestions.toList();
              if (list.isEmpty) return const SizedBox.shrink();
              return list.first;
            },
          ),
        ),
      ],
    );
  }
}

/// Opens the global search overlay. Used by shell navigation items.
void openSearchOverlay(SearchController controller) {
  controller.openView();
}

class _SearchOverlayPanel extends ConsumerWidget {
  const _SearchOverlayPanel({required this.onTaskTap});

  final ValueChanged<String> onTaskTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final query = ref.watch(app_search.searchControllerProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Material(
      elevation: 4,
      child: SizedBox(
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FilterChipsRow(),
            Expanded(
              child: resultsAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const EmptyState();
                  }
                  return ResultList(
                    tasks: tasks,
                    keyword: query.effectiveKeyword,
                    onTaskTap: onTaskTap,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => EmptyState(
                  message:
                      l10n?.searchFailed(err.toString()) ??
                      'Search failed: $err',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
