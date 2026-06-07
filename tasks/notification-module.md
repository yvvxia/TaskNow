# 通知模块任务清单 / Notification Module Tasks

> Source: `design/05-notification-module.md`  
> Depends on: `tasks/architecture-overview.md`, `tasks/task-module.md`, `tasks/platform-settings-sync.md`  
> Status: Complete

## 目标 / Goal

实现任务提醒计算、系统通知调度、通知动作处理、免打扰、权限降级、启动对账与任务变更后的通知重排。

## Checklist

- [x] 创建 `Reminder`、`ReminderDraft`、`NotificationRequest`、`NotificationAction` 模型。
- [x] 创建 `NotificationActionType` 枚举：markDone / snooze / open。
- [x] 定义 `INotificationService` 接口：requestPermission、schedule、cancel、cancelForTask、pending、onAction。
- [x] 实现 `ReminderCalculator.compute()`。
- [x] 实现截止前提醒计算：`dueDate - offsetMin`。
- [x] 实现开始时提醒计算：`startDate`。
- [x] 实现自定义提醒：使用用户设置的绝对时间。
- [x] 实现逾期提醒首次触发与后续重复计算。
- [x] 过滤已过期的非逾期提醒。
- [x] 创建 `ReminderScheduler`。
- [x] 实现 `ReminderScheduler.sync(task)`，先取消旧通知，再计算与持久化提醒，再调度新通知。
- [x] 实现 `ReminderScheduler.cancel(taskId)`。
- [x] 实现通知正文模板：`[项目名] · 截止 MM-dd HH:mm`。
- [x] 实现稳定通知 ID 映射或持久化 `notif_id`。
- [x] 实现免打扰判断 `isInDnd()`。
- [x] 实现 DND 时段内跳过非逾期通知。
- [x] 实现逾期是否忽略 DND 的设置接入。
- [x] 实现通知动作监听 Provider。
- [x] 实现 markDone 动作，调用 `CompleteTaskUseCase`。
- [x] 实现 snooze 动作，15 分钟后重新提醒。
- [x] 实现 open 动作，打开任务详情页。
- [x] 添加 Android 通知实现，使用 `flutter_local_notifications`。
- [x] Android 处理精确闹钟权限，未授权时降级。
- [x] 添加 Windows Toast 通知实现或插件适配。
- [ ] 实现通知未授权提示与设置页入口。
- [x] 实现启动对账 `reconcileOnLaunch()`。
- [x] 对账时补调度缺失通知并清理已完成任务通知。
- [x] 任务创建/更新/完成/删除时接入通知重排或取消。

## 验收标准 / Acceptance Criteria

- [x] 截止前、开始时、自定义、逾期四类提醒可被正确计算。
- [x] 任务更新日期后旧通知被取消，新通知被调度。
- [x] 任务完成或删除后关联通知被取消。
- [x] 通知动作“标记完成”能完成任务。
- [x] 通知动作“稍后提醒”能 15 分钟后重新提醒。
- [x] 免打扰时段规则生效。
- [x] 启动对账能补齐遗漏的待触发通知。

## 测试 / Tests

- [x] `ReminderCalculator` 各类型触发时间测试。
- [x] 过去时间过滤测试。
- [x] 逾期续推测试。
- [x] `ReminderScheduler.sync()` 先 cancel 后 schedule 测试。
- [x] DND 跳过测试。
- [x] 通知关闭时不调度测试。
- [x] markDone / snooze / open 动作映射测试。
- [x] `reconcileOnLaunch()` 补调度测试。
