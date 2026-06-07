import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask.freezed.dart';
part 'subtask.g.dart';

/// Subtask (checklist item) nested inside a [Task].
@freezed
abstract class Subtask with _$Subtask {
  const factory Subtask({
    required String id,
    required String title,
    @Default(false) bool isDone,
    @Default(0) int sortOrder,
  }) = _Subtask;

  factory Subtask.fromJson(Map<String, dynamic> json) => _$SubtaskFromJson(json);
}
