import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/utils/fts_tokenizer.dart';

void main() {
  group('buildFtsMatch', () {
    test('CJK text becomes adjacent 2-gram quoted tokens joined with AND', () {
      expect(buildFtsMatch('需求文档'), '"需求" AND "求文" AND "文档"');
    });

    test('single CJK character is quoted once', () {
      expect(buildFtsMatch('需'), '"需"');
    });

    test('Latin words become prefix tokens', () {
      expect(buildFtsMatch('buy milk'), 'buy* AND milk*');
    });

    test('mixed English and Chinese segments', () {
      expect(buildFtsMatch('report 需求'), 'report* AND "需求"');
    });
  });

  group('splitByScript', () {
    test('splits alternating Latin and CJK runs', () {
      final segments = splitByScript('abc 中文 def');
      expect(segments.length, 3);
      expect(segments[0].text, 'abc');
      expect(segments[0].isCjk, isFalse);
      expect(segments[1].text, '中文');
      expect(segments[1].isCjk, isTrue);
      expect(segments[2].text, 'def');
    });
  });

  group('highlightTerms', () {
    test('includes CJK bigrams for UI highlight', () {
      final terms = highlightTerms('需求');
      expect(terms, contains('需求'));
    });

    test('includes latin words lowercased', () {
      final terms = highlightTerms('Milk');
      expect(terms, contains('milk'));
    });
  });
}
