# 架构总览任务清单 / Architecture Overview Tasks

> Source: `design/00-architecture-overview.md`  
> Status: Done

## 目标 / Goal

建立 Flutter 项目基础架构：分层目录、核心契约、错误处理、依赖注入、路由、自适应 Shell 与全局约定。

## Checklist

- [x] 初始化 Flutter 项目，启用 Windows 与 Android 平台支持。
- [x] 配置基础依赖：`flutter_riverpod`、`riverpod_generator`、`go_router`、`freezed`、`json_serializable`、`build_runner`、`intl`。
- [x] 创建目录结构：`lib/core`、`lib/data`、`lib/features`、`lib/platform`、`lib/l10n`、`test`。
- [x] 创建 `core/contracts` 目录与跨模块接口文件占位。
- [x] 创建 `core/models`、`core/enums`、`core/errors`、`core/utils`。
- [x] 实现 `Result<T>`、`Ok<T>`、`Err<T>` 统一返回类型。
- [x] 实现 `AppException` 基类与 `ValidationException`、`NotFoundException`、`PersistenceException`、`PermissionException`。
- [x] 定义全局枚举：`Priority`、`TaskStatus`、`ReminderType`、`RecurrenceFrequency`、`CalendarViewType`、`TaskSort`。
- [x] 定义 `clockProvider`，支持测试中注入固定时间。
- [x] 创建基础设施 Provider：`taskRepositoryProvider`、`projectRepositoryProvider`、`tagRepositoryProvider`、`reminderRepositoryProvider`、`notificationServiceProvider`、`settingsStoreProvider`、`syncEngineProvider`。
- [x] 创建 `main.dart` 启动骨架，预留数据库、设置、通知服务初始化。
- [x] 创建 `app.dart`，接入 `MaterialApp.router` 与 `go_router`。
- [x] 配置路由：`/tasks`、`/calendar`、`/search`、`/settings`、`/task/:id`。
- [x] 实现 `AdaptiveScaffold`，支持 compact / medium / expanded 三类布局。
- [x] 实现移动端底部导航与桌面端侧边栏布局骨架。
- [x] 实现桌面端任务详情右侧面板与移动端全屏详情路由的适配策略。
- [x] 配置代码生成脚本与 `build_runner` 命令。
- [x] 配置 `flutter_lints`。
- [x] 规划或实现分层 import 约束，禁止 presentation/domain 直接依赖 `data` 或 `platform`。（已在 `analysis_options.yaml` 记录规划；自定义 import-lint 规则为可选，本模块未实现，留有 TODO。）

## 验收标准 / Acceptance Criteria

- [x] 应用可以启动到空的任务页、日历页、搜索页、设置页。
- [x] 所有基础 Provider 可在 `main()` 中被 override。
- [x] `go_router` 路由切换正常。
- [x] 窄屏使用底部导航，宽屏使用侧边栏布局。
- [x] `flutter analyze` 无错误。

## 测试 / Tests

- [x] `Result<T>` 和异常类型单元测试。
- [x] `AdaptiveScaffold` 断点 widget 测试。
- [x] 路由表基础跳转测试。
- [x] Provider override 测试，确认 fake 实现可替换真实实现。
