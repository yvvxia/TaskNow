import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/di/clock.dart';

void main() {
  test('clockProvider defaults to a now-like clock', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final clock = container.read(clockProvider);
    final before = DateTime.now();
    final now = clock();
    final after = DateTime.now();

    expect(now.isBefore(before.subtract(const Duration(seconds: 1))), isFalse);
    expect(now.isAfter(after.add(const Duration(seconds: 1))), isFalse);
  });

  test('clockProvider can be overridden with a fixed clock', () {
    final fixed = DateTime.utc(2026, 6, 7, 2, 28);
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => fixed)],
    );
    addTearDown(container.dispose);

    expect(container.read(clockProvider)(), fixed);
  });
}
