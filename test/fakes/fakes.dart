// Canonical barrel for the standard repository/service fakes
// (`design/07-testing-strategy.md` §3). Settings and sync fakes live in their
// own files (`fake_settings_store.dart`, `fake_sync_engine.dart`) so callers
// can import them independently without ambiguity.
export 'fake_project_repository.dart';
export 'fake_reminder_repository.dart';
export 'fake_tag_repository.dart';
export 'fake_task_repository.dart';
export 'spy_notification_service.dart';
