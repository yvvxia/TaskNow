import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/enums/status_filter.dart';
import 'package:liveline/core/models/task_query.dart';
import 'package:liveline/features/search/search_controller.dart';

void main() {
  test('setKeyword debounces updates to 250ms', () {
    fakeAsync((async) {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.listen(searchControllerProvider, (_, _) {});

      final notifier = container.read(searchControllerProvider.notifier);
      expect(container.read(searchControllerProvider).keyword, isNull);

      notifier.setKeyword('a');
      notifier.setKeyword('ab');
      notifier.setKeyword('abc');
      expect(container.read(searchControllerProvider).keyword, isNull);

      async.elapse(const Duration(milliseconds: 249));
      expect(container.read(searchControllerProvider).keyword, isNull);

      async.elapse(const Duration(milliseconds: 1));
      expect(container.read(searchControllerProvider).keyword, 'abc');
    });
  });

  test('clear resets query to default search state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(searchControllerProvider.notifier);
    notifier.setStatus(StatusFilter.complete);
    notifier.clear();

    final query = container.read(searchControllerProvider);
    expect(query, const TaskQuery(includeCompleted: false));
    expect(query.statusFilter, StatusFilter.all);
  });
}
