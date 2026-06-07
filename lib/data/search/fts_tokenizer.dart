import 'package:flutter/painting.dart' show TextSpan;

/// Script segment produced by [_splitByScript].
class ScriptSegment {
  const ScriptSegment({required this.text, required this.isCjk});

  final String text;
  final bool isCjk;
}

final RegExp _cjkRun = RegExp(
  r'[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]+',
);

/// Splits [raw] into alternating Latin and CJK script runs.
List<ScriptSegment> splitByScript(String raw) {
  if (raw.isEmpty) return const [];

  final segments = <ScriptSegment>[];
  var index = 0;

  for (final match in _cjkRun.allMatches(raw)) {
    if (match.start > index) {
      final latin = raw.substring(index, match.start).trim();
      if (latin.isNotEmpty) {
        segments.add(ScriptSegment(text: latin, isCjk: false));
      }
    }
    segments.add(ScriptSegment(text: match.group(0)!, isCjk: true));
    index = match.end;
  }

  if (index < raw.length) {
    final latin = raw.substring(index).trim();
    if (latin.isNotEmpty) {
      segments.add(ScriptSegment(text: latin, isCjk: false));
    }
  }

  return segments;
}

/// Builds an FTS5 MATCH expression with CJK 2-grams and Latin prefix tokens.
String buildFtsMatch(String raw) {
  final tokens = <String>[];
  for (final segment in splitByScript(raw.trim())) {
    if (segment.isCjk) {
      final text = segment.text;
      if (text.length == 1) {
        tokens.add('"$text"');
      } else {
        for (var i = 0; i < text.length - 1; i++) {
          tokens.add('"${text.substring(i, i + 2)}"');
        }
      }
    } else {
      for (final word in segment.text.split(RegExp(r'\s+'))) {
        if (word.isEmpty) continue;
        final escaped = word.replaceAll('"', '');
        if (escaped.isNotEmpty) {
          tokens.add('$escaped*');
        }
      }
    }
  }
  if (tokens.isEmpty) return raw.trim();
  return tokens.join(' AND ');
}

/// Returns lowercase keyword fragments used for UI highlighting.
List<String> highlightTerms(String? keyword) {
  if (keyword == null || keyword.trim().isEmpty) return const [];
  final terms = <String>[];
  for (final segment in splitByScript(keyword.trim())) {
    if (segment.isCjk) {
      terms.add(segment.text.toLowerCase());
      if (segment.text.length > 1) {
        for (var i = 0; i < segment.text.length - 1; i++) {
          terms.add(segment.text.substring(i, i + 2).toLowerCase());
        }
      }
    } else {
      for (final word in segment.text.split(RegExp(r'\s+'))) {
        if (word.isNotEmpty) terms.add(word.toLowerCase());
      }
    }
  }
  return terms;
}

/// Builds [TextSpan]s with matching substrings emphasized.
List<TextSpan> buildHighlightSpans(
  String text,
  String? keyword, {
  TextSpan Function(String segment, {required bool isMatch})? spanBuilder,
}) {
  final terms = highlightTerms(keyword);
  if (terms.isEmpty) {
    return [TextSpan(text: text)];
  }

  final lower = text.toLowerCase();
  final matches = <({int start, int end})>[];

  for (final term in terms) {
    var start = 0;
    while (true) {
      final idx = lower.indexOf(term, start);
      if (idx == -1) break;
      matches.add((start: idx, end: idx + term.length));
      start = idx + 1;
    }
  }

  if (matches.isEmpty) {
    return [TextSpan(text: text)];
  }

  matches.sort((a, b) => a.start.compareTo(b.start));
  final merged = <({int start, int end})>[];
  for (final m in matches) {
    if (merged.isEmpty || m.start > merged.last.end) {
      merged.add(m);
    } else if (m.end > merged.last.end) {
      merged[merged.length - 1] = (
        start: merged.last.start,
        end: m.end,
      );
    }
  }

  final spans = <TextSpan>[];
  var cursor = 0;
  final build = spanBuilder ??
      (segment, {required isMatch}) => TextSpan(
            text: segment,
            style: isMatch ? const TextSpan().style : null,
          );

  for (final m in merged) {
    if (cursor < m.start) {
      spans.add(build(text.substring(cursor, m.start), isMatch: false));
    }
    spans.add(build(text.substring(m.start, m.end), isMatch: true));
    cursor = m.end;
  }
  if (cursor < text.length) {
    spans.add(build(text.substring(cursor), isMatch: false));
  }
  return spans;
}
