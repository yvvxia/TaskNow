import 'package:liveline/core/models/tag.dart';

int _seq = 0;

void resetTagSeq() => _seq = 0;

/// Builds a [Tag] with test defaults.
Tag aTag({String? id, String name = 'Test tag', String? color}) {
  return Tag(id: id ?? 'tag-${_seq++}', name: name, color: color);
}
