# 数据与持久化任务清单 / Data & Persistence Tasks

> Source: `design/01-data-and-persistence.md`  
> Depends on: `tasks/architecture-overview.md`  
> Status: Done

## 目标 / Goal

实现本地优先 SQLite 数据层，包含 Drift schema、DAO、Repository、Mapper、FTS5、迁移、软删除与默认数据。

## Checklist

- [x] 添加依赖：`drift`、`drift_dev`、`sqlite3_flutter_libs`、`path_provider`、`path`、`uuid`。
- [x] 创建 `lib/data/db/app_database.dart`。
- [x] 创建 Drift 表：`Projects`、`Tasks`、`Subtasks`、`Tags`、`TaskTags`、`Reminders`、`RecurrenceRules`。
- [x] 在 `Tasks` 表中加入日期、优先级、完成状态、重复规则、同步预留字段。
- [x] 在 `Tasks` 表中加入 `start_date <= due_date` 的业务约束。
- [x] 创建索引：`idx_task_due`、`idx_task_start`、`idx_task_completed`、`idx_task_project`、`idx_task_deleted`、`idx_reminder_trig`、`idx_subtask_task`。
- [x] 创建 FTS5 虚拟表 `tasks_fts`。
- [x] 创建 FTS 同步触发器：insert / update / delete。
- [x] 启用 `PRAGMA foreign_keys = ON`。
- [x] 实现数据库连接 `openConnection()`，支持 Windows 与 Android 文件路径。
- [x] 创建默认项目 seed：`Inbox / 收件箱`。
- [x] 创建 `TaskDao`，实现区间查询、动态查询、FTS 查询、多表 upsert。
- [x] 创建 `ProjectDao`、`TagDao`、`ReminderDao`。
- [x] 创建 `TaskMapper`，实现 `TaskRow` 与 `Task` 的双向映射。
- [x] 创建 `ProjectMapper`、`TagMapper`、`ReminderMapper`、`RecurrenceRuleMapper`。
- [x] 实现 `DriftTaskRepository`，覆盖 `create`、`update`、`delete`、`findById`、`findInRange`、`query`、`watch`。
- [x] 实现 `DriftProjectRepository`。
- [x] 实现 `DriftTagRepository`。
- [x] 实现 `DriftReminderRepository`。
- [x] 实现软删除：删除操作写入 `deleted_at`，默认查询过滤软删除记录。
- [x] 实现 UTC 毫秒与 `DateTime` 的转换工具。
- [x] 创建 `newTestDb()` 测试辅助函数，使用 `NativeDatabase.memory()`。
- [x] 配置 drift schema 生成与迁移测试基础。

## 验收标准 / Acceptance Criteria

- [x] 数据库首次启动能自动建表、建索引、建 FTS 表并 seed 默认项目。
- [x] 任务 CRUD 可正常持久化并通过 `watch` 响应式更新。
- [x] 多表写入在事务中完成，失败时不产生部分写入。
- [x] 区间查询只返回与给定日期范围相交的任务。
- [x] FTS 查询能搜索标题与备注。
- [x] 软删除任务不会出现在默认查询结果中。

## 测试 / Tests

- [x] Mapper 往返测试。
- [x] DAO 区间查询交集测试。
- [x] Repository CRUD 测试。
- [x] FTS 触发器 insert/update/delete 同步测试。
- [x] 软删除隐藏测试。
- [x] 数据库迁移测试占位。
