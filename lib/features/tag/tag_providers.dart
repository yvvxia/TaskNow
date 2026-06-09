import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/models/tag.dart';
import 'domain/create_tag_usecase.dart';

/// All tags for sidebar / filter UI.
final tagListProvider = StreamProvider<List<Tag>>((ref) {
  return ref.watch(tagRepositoryProvider).watchAll();
});

/// Creates a new tag (validates the name first).
final createTagUseCaseProvider = Provider<CreateTagUseCase>(
  (ref) => CreateTagUseCase(ref.watch(tagRepositoryProvider)),
);
