import 'package:plan_list/core/models/project.dart';

int _seq = 0;

void resetProjectSeq() => _seq = 0;

/// Builds a [Project] with test defaults.
Project aProject({
  String? id,
  String name = 'Test project',
  String? color,
  int sortOrder = 0,
}) {
  return Project(
    id: id ?? 'project-${_seq++}',
    name: name,
    color: color,
    sortOrder: sortOrder,
  );
}
