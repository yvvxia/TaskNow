import '../../core/models/tag.dart';
import '../db/app_database.dart';

/// Pure, bidirectional mapping between [TagRow] and [Tag].
abstract final class TagMapper {
  static Tag toEntity(TagRow row) =>
      Tag(id: row.id, name: row.name, color: row.color);

  static TagRow toRow(Tag tag) =>
      TagRow(id: tag.id, name: tag.name, color: tag.color);
}
