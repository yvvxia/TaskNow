import 'package:flutter_riverpod/legacy.dart';

/// Task id shown in the desktop right detail panel (expanded layout).
final selectedTaskIdProvider = StateProvider<String?>((ref) => null);

/// Whether the desktop sidebar is collapsed to icon-only mode.
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
