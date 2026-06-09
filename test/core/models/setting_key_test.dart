import 'package:flutter_test/flutter_test.dart';
import 'package:liveline/core/models/setting_key.dart';

void main() {
  test('SettingKey exposes name and default value', () {
    final k = SettingKey<int>('reminder', 15);
    expect(k.name, 'reminder');
    expect(k.defaultValue, 15);
    expect(k.toString(), contains('reminder'));
    expect(k.toString(), contains('int'));
  });

  test('SettingKey equality and hashCode', () {
    const a = SettingKey<int>('reminder', 15);
    const b = SettingKey<int>('reminder', 15);
    const differentDefault = SettingKey<int>('reminder', 30);
    const differentName = SettingKey<int>('other', 15);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == differentDefault, isFalse);
    expect(a == differentName, isFalse);
  });
}
