import 'package:flutter_test/flutter_test.dart';
import 'package:plan_list/core/errors/app_exception.dart';
import 'package:plan_list/core/utils/result.dart';

void main() {
  group('Result', () {
    test('Ok exposes value and flags', () {
      final Result<int> r = Ok<int>(42);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      expect(r.valueOrNull, 42);
      expect(r.errorOrNull, isNull);
      expect((r as Ok<int>).value, 42);
    });

    test('Err exposes error and flags', () {
      final err = ValidationException();
      final Result<int> r = Err<int>(err);
      expect(r.isOk, isFalse);
      expect(r.isErr, isTrue);
      expect(r.valueOrNull, isNull);
      expect(r.errorOrNull, same(err));
      expect((r as Err<int>).error, same(err));
    });

    test('fold maps the Ok branch', () {
      final Result<int> r = Ok<int>(3);
      final out = r.fold((v) => 'ok:$v', (e) => 'err:${e.code}');
      expect(out, 'ok:3');
    });

    test('fold maps the Err branch', () {
      final Result<int> r = Err<int>(NotFoundException());
      final out = r.fold((v) => 'ok:$v', (e) => 'err:${e.code}');
      expect(out, 'err:not_found');
    });
  });
}
