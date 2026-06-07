import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_draft.freezed.dart';

/// Draft (input) for creating a subtask.
@freezed
abstract class SubtaskDraft with _$SubtaskDraft {
  const factory SubtaskDraft({
    required String title,
    @Default(false) bool isDone,
    @Default(0) int sortOrder,
  }) = _SubtaskDraft;
}
