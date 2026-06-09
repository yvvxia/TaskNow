import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/errors/app_exception.dart';

void main() {
  test('ValidationException has defaults and is an Exception', () {
    const e = ValidationException();
    expect(e, isA<AppException>());
    expect(e, isA<Exception>());
    expect(e.code, 'validation');
    expect(e.messageKey, 'error.validation');
    expect(e.toString(), contains('ValidationException'));
    expect(e.toString(), contains('validation'));
    expect(e.toString(), contains('error.validation'));
  });

  test('ValidationException accepts custom code/messageKey', () {
    const e = ValidationException(
      code: 'dueBeforeStart',
      messageKey: 'error.dueBeforeStart',
    );
    expect(e.code, 'dueBeforeStart');
    expect(e.messageKey, 'error.dueBeforeStart');
  });

  test('NotFoundException defaults', () {
    const e = NotFoundException();
    expect(e.code, 'not_found');
    expect(e.messageKey, 'error.notFound');
  });

  test('PersistenceException defaults', () {
    const e = PersistenceException();
    expect(e.code, 'persistence');
    expect(e.messageKey, 'error.persistence');
  });

  test('PermissionException defaults', () {
    const e = PermissionException();
    expect(e.code, 'permission');
    expect(e.messageKey, 'error.permission');
    expect(e.toString(), contains('PermissionException'));
  });
}
