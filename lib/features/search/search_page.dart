import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'presentation/empty_state.dart';
import 'presentation/filter_chips_row.dart';
import 'presentation/result_list.dart';
import 'presentation/search_bar.dart';
import 'search_controller.dart';
import 'search_providers.dart';

/// Full search screen with debounced keyword input, filter chips, and results.
class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      return const SizedBox(key: Key('search-page'));
    }

    final query = ref.watch(searchControllerProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final l10n = AppLocalizations.of(context);

    return Column(
      key: const Key('search-page'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TaskSearchBar(),
        const FilterChipsRow(),
        Expanded(
          child: resultsAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return const EmptyState();
              }
              return ResultList(tasks: tasks, keyword: query.effectiveKeyword);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => EmptyState(
              message:
                  l10n?.searchFailed(err.toString()) ?? 'Search failed: $err',
            ),
          ),
        ),
      ],
    );
  }
}
