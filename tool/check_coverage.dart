// Parses an lcov.info file and reports line coverage per architectural layer,
// warning when a layer falls below the thresholds in
// `design/07-testing-strategy.md` §7.
//
// Usage:
//   dart run tool/check_coverage.dart [path-to-lcov] [--strict]
//
// Thresholds: domain >= 90%, data >= 80%, overall >= 75%.
// By default the script only *warns* (exit 0) so incomplete local coverage
// data never blocks CI. Pass --strict to fail (exit 1) on any breach.
import 'dart:io';

const _thresholds = <String, double>{
  'domain': 90.0,
  'data': 80.0,
  'overall': 75.0,
};

class _Counter {
  int found = 0;
  int hit = 0;
  void add(int da, int hits) {
    found += 1;
    if (hits > 0) hit += 1;
  }

  double get pct => found == 0 ? 100.0 : (hit / found) * 100.0;
}

void main(List<String> args) {
  final strict = args.contains('--strict');
  final pathArg = args.firstWhere(
    (a) => !a.startsWith('--'),
    orElse: () => 'coverage/lcov.info',
  );

  final file = File(pathArg);
  if (!file.existsSync()) {
    stderr.writeln('WARNING: coverage file not found at $pathArg — skipping.');
    exit(0);
  }

  final domain = _Counter();
  final data = _Counter();
  final overall = _Counter();

  String? currentFile;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll('\\', '/');
    } else if (line.startsWith('DA:') && currentFile != null) {
      final parts = line.substring(3).split(',');
      if (parts.length < 2) continue;
      final hits = int.tryParse(parts[1]) ?? 0;
      overall.add(0, hits);
      if (currentFile.contains('/domain/')) domain.add(0, hits);
      if (currentFile.contains('/data/')) data.add(0, hits);
    } else if (line == 'end_of_record') {
      currentFile = null;
    }
  }

  final results = <String, _Counter>{
    'domain': domain,
    'data': data,
    'overall': overall,
  };

  stdout.writeln('── Coverage summary ──────────────────────────────');
  var breached = false;
  results.forEach((layer, counter) {
    final pct = counter.pct;
    final threshold = _thresholds[layer]!;
    final ok = pct >= threshold;
    if (!ok) breached = true;
    final flag = ok ? 'OK ' : 'LOW';
    stdout.writeln(
      '  [$flag] ${layer.padRight(8)} '
      '${pct.toStringAsFixed(1).padLeft(5)}% '
      '(${counter.hit}/${counter.found} lines, need >= ${threshold.toStringAsFixed(0)}%)',
    );
  });
  stdout.writeln('──────────────────────────────────────────────────');

  if (breached) {
    stderr.writeln(
      strict
          ? 'ERROR: coverage below threshold (strict mode).'
          : 'WARNING: coverage below threshold (non-blocking).',
    );
    exit(strict ? 1 : 0);
  }
  stdout.writeln('All coverage thresholds met.');
}
