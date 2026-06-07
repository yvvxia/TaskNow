# 测试策略任务清单 / Testing Strategy Tasks

> Source: `design/07-testing-strategy.md`  
> Depends on: all implementation modules  
> Status: Done

## 目标 / Goal

建立可持续的测试体系：单元测试、数据层测试、集成测试、Widget/Golden 测试、测试 Fake、测试数据构建器与 CI 门禁。

## Checklist

- [x] 创建测试目录结构：`test/unit`、`test/data`、`test/integration`、`test/widget`、`test/fakes`、`test/builders`。（另含 `test/performance`）
- [x] 添加测试依赖：`flutter_test`、`mocktail`、`golden_toolkit`、`fake_async`。
- [x] 创建 `ProviderContainer` 测试辅助函数。（`test/fakes/make_container.dart`）
- [x] 创建 `FakeTaskRepository`，支持内存列表与 `StreamController`。
- [x] 创建 `FakeReminderRepository`。
- [x] 创建 `SpyNotificationService`，记录 scheduled、cancelled、actions。
- [x] 创建 `FakeSettingsStore`。
- [x] 创建 `FakeSyncEngine`。
- [x] 创建 `clockProvider` 测试 override 规范。（`makeContainer` 默认 `kTestNow`）
- [x] 创建 `task_builder.dart`。
- [x] 创建 `project_builder.dart`、`tag_builder.dart`、`reminder_builder.dart`。
- [x] 创建数据层内存数据库辅助函数 `newTestDb()`。（已存在，`test/builders/builders.dart` 重新导出）
- [x] 编写 01 数据模块测试：Mapper、DAO、Repository、FTS、软删除。
- [x] 编写 02 任务模块测试：重复引擎、用例副作用、子任务自动完成、校验。
- [x] 编写 03 日历模块测试：布局、坐标映射、拖拽、视图窗口。
- [x] 编写 04 搜索模块测试：查询组合、分词、防抖、空状态。
- [x] 编写 05 通知模块测试：提醒计算、调度顺序、DND、动作、对账。
- [x] 编写 06 平台设置测试：设置存储、主题、ARB、同步 no-op。
- [x] 编写跨模块集成测试：创建任务 -> 调度提醒 -> 出现在日历区间。
- [x] 编写 `TaskTile` 多状态 golden 测试。
- [x] 编写桌面/移动布局 golden 测试。
- [x] 编写 1000 条任务性能种子数据生成器。（`test/builders/seed_data.dart`）
- [x] 编写月视图查询性能测试。
- [x] 编写列表滚动性能/回归测试。
- [x] 创建 CI 草案：pub get、build_runner、format、analyze、test、coverage。（`.github/workflows/ci.yml`）
- [x] 设置覆盖率门禁：领域层 ≥ 90%、数据层 ≥ 80%、整体 ≥ 75%。（`tool/check_coverage.dart`）
- [x] 设置分层依赖违规门禁：0 违规。（`tool/check_layer_imports.sh` + `tool/import_lint.md`）

## 验收标准 / Acceptance Criteria

- [x] 每个模块都能使用 Fake 独立测试。
- [x] 数据层测试可使用内存 SQLite，不依赖真实文件。
- [x] 关键领域算法有确定性单元测试。
- [x] Widget/Golden 覆盖任务关键状态与自适应布局。
- [x] CI 能运行格式化、静态分析和测试。
- [x] 覆盖率报告可生成。

## 测试 / Tests

- [x] 测试工具自身可在示例测试中通过。
- [x] Fake repository 的 stream 行为测试。（`test/fakes/fake_task_repository_test.dart`）
- [x] Spy notification service 记录行为测试。（`test/fakes/spy_notification_service_test.dart`）
- [x] Builder 默认值测试。（`test/builders/task_builder_test.dart`）
