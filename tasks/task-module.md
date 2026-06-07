# 任务模块任务清单 / Task Module Tasks

> Source: `design/02-task-module.md`  
> Depends on: `tasks/architecture-overview.md`, `tasks/data-and-persistence.md`, `tasks/notification-module.md`  
> Status: Complete

## 目标 / Goal

实现任务领域核心：任务/子任务模型、创建/编辑/完成/删除用例、重复任务引擎、状态派生、清单 Provider 与任务 UI。

## Checklist

- [x] 创建 `Task`、`Subtask`、`TaskDraft`、`SubtaskDraft` 不可变模型。
- [x] 创建 `Tag`、`Project`、`Reminder`、`RecurrenceRule` 领域模型引用。
- [x] 实现 `Task.statusAt(DateTime now)`，派生 `incomplete / complete / overdue`。
- [x] 实现 `Task.subtaskProgress`。
- [x] 定义 `TaskListScope`，支持项目、标签、今天、逾期、已完成等清单上下文。
- [x] 实现 `TaskListScope.toQuery()`，转换为 `TaskQuery`。
- [x] 实现任务校验器：标题非空、`dueDate >= startDate`、提醒配置合法。
- [x] 实现 `CreateTaskUseCase`。
- [x] 实现 `UpdateTaskUseCase`。
- [x] 实现 `CompleteTaskUseCase`，完成任务时写入 `completedAt`。
- [x] 在完成任务时取消关联通知。
- [x] 完成重复任务后生成下一实例。
- [x] 实现 `ToggleSubtaskUseCase`。
- [x] 实现所有子任务完成时自动完成父任务的逻辑。
- [x] 实现 `DeleteTaskUseCase`，支持删除单次与整个系列。
- [x] 实现 `ReorderTasksUseCase`。
- [x] 实现 `RecurrenceEngine.nextDate()`，支持 daily / weekly / monthly。
- [x] 实现 `RecurrenceEngine.nextInstance()`，保留任务属性并重置完成状态与子任务状态。
- [x] 处理月底重复边界：如 1/31 到 2 月取当月最后一天。
- [x] 处理重复规则 `endDate` 与 `count` 结束条件。
- [x] 创建任务相关 UseCase Provider。
- [x] 实现 `TaskListNotifier`，基于 `repository.watch()` 输出 `TaskView`。
- [x] 实现 `TaskView`，包含本地化日期、逾期标记、子任务徽标、优先级展示数据。
- [x] 创建 `TaskListPage`。
- [x] 创建 `TaskTile`，支持完成复选框、优先级、日期范围、子任务进度。
- [x] 创建 `TaskDetailPage` 与 `TaskDetailPanel`。
- [x] 创建任务表单区块：标题、日期、项目、标签、优先级、子任务、提醒、重复、备注、元信息。
- [x] 实现移动端 FAB / bottom sheet 新建入口。
- [x] 实现桌面端顶部快速输入框。
- [x] 实现移动端左滑完成或点击完成。
- [x] 实现批量选择与批量完成/移动/删除的 UI 占位或基础能力。

## 验收标准 / Acceptance Criteria

- [x] 用户可创建、编辑、完成、删除任务。
- [x] 创建日期与完成日期由系统自动记录。
- [x] 开始日期与截止日期校验正确。
- [x] 子任务可增删改并显示进度。
- [x] 重复任务完成后能生成下一实例。
- [x] 逾期任务在列表中被正确标记。
- [x] 任务详情在桌面为右侧面板，在移动端为全屏页。

## 测试 / Tests

- [x] `RecurrenceEngine` daily / weekly / monthly 单元测试。
- [x] 月底日期边界测试。
- [x] `CreateTaskUseCase` 校验失败测试。
- [x] `CompleteTaskUseCase` 副作用顺序测试：完成 -> 取消通知 -> 生成下一实例。
- [x] `ToggleSubtaskUseCase` 自动完成父任务测试。
- [x] `TaskListNotifier` 使用 fake repo 与固定 clock 测试逾期派生。
- [x] `TaskTile` 正常 / 逾期 / 已完成 golden 测试。
