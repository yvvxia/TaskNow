# 日历与甘特模块任务清单 / Calendar & Gantt Module Tasks

> Source: `design/03-calendar-gantt-module.md`  
> Depends on: `tasks/architecture-overview.md`, `tasks/task-module.md`, `tasks/search-filter-module.md`  
> Status: Complete

## 目标 / Goal

实现日 / 周 / 月 / 甘特四种任务视图，支持区间查询、时间轴布局、任务条渲染与拖拽创建/移动/调整。

## Checklist

- [x] 创建 `CalendarViewState` 模型，包含视图类型、锚点日期、可见范围、选中任务。
- [x] 创建 `CalendarViewType` 枚举：day / week / month / gantt。
- [x] 创建 `TaskBar` 视图模型，包含任务、条开始/结束、行号、逾期状态、颜色。
- [x] 实现 `CalendarViewStateNotifier`。
- [x] 实现视图切换逻辑，保持 `anchor` 不变并重算 `visibleRange`。
- [x] 实现 `next()`、`prev()`、`goToToday()`。
- [x] 实现不同视图的 `visibleRange` 计算：日、周、月、甘特。
- [x] 实现 `visibleBarsProvider`，使用 `TaskQuery.rangeOverlap()` 查询可见任务。
- [x] 实现 `GanttLayout.assign()` 贪心行分配算法。
- [x] 实现任务日期归一化：`startDate ?? dueDate` 与 `dueDate ?? startDate`。
- [x] 实现单日任务渲染回退。
- [x] 实现颜色解析：按优先级或项目色。
- [x] 创建 `TimeAxis`，支持 date -> dx 与 dx -> date。
- [x] 实现吸附到天边界的 `snapToDay()`。
- [x] 定义拖拽意图：`CreateDrag`、`MoveDrag`、`ResizeDrag`。
- [x] 实现 `GanttInteractionController.apply()`。
- [x] 实现空白区域拖拽创建任务。
- [x] 实现拖动任务条整体平移，保持原时长。
- [x] 实现拖动左/右边缘调整开始或截止日期。
- [x] 实现拖拽越界时回弹，不写入仓储。
- [x] 调整任务日期成功后调用 `UpdateTaskUseCase` 触发通知重排。
- [x] 实现 `DayView`，按 24 小时纵轴展示任务块。
- [x] 实现 `WeekView`，7 列展示任务，支持多日任务顶部泳道。
- [x] 实现 `MonthView`，网格展示任务点/短条和 `+k more`。
- [x] 实现 `GanttView`，双向滚动展示任务行与横向时间轴。
- [x] 实现桌面端直接拖拽交互。
- [x] 实现移动端长按进入拖拽模式。
- [x] 实现任务点击打开详情。
- [x] 实现“今天”按钮、日期前后导航与视图 tab。

## 验收标准 / Acceptance Criteria

- [x] 日、周、月、甘特四种视图都可展示任务。
- [x] 甘特条长度和位置与开始/截止日期一致。
- [x] 重叠任务被分配到不同泳道。
- [x] 视图切换后日期窗口保持一致。
- [x] 拖拽创建、移动、调整边缘均可用。
- [x] 移动端拖拽不会与滚动严重冲突。

## 测试 / Tests

- [x] `GanttLayout.assign()` 重叠分行测试。
- [x] 单日回退测试。
- [x] `TimeAxis` 坐标与日期往返测试。
- [x] `ResizeDrag` 导致 `start > due` 时不写库测试。
- [x] 视图切换保持 anchor 测试。
- [x] 周视图和甘特视图 golden 测试。
- [x] 拖拽手势 widget 测试。
