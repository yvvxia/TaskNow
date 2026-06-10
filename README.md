# Liveline

> 一款跨平台（Android + Windows 桌面）的任务 / 日程规划应用，内置日历、甘特图、提醒、循环任务、全文搜索与中英文双语支持。

Liveline 用 Flutter 构建，采用 **Riverpod**（状态管理与依赖注入）、**Drift**（本地 SQLite 持久化）、**go_router**（路由）三大基础设施，并以严格的分层架构保证可测试性与可维护性。

---

## 目录

- [一、项目概览](#一项目概览)
- [二、技术栈](#二技术栈)
- [三、信息架构](#三信息架构)
- [四、目录结构](#四目录结构)
- [五、数据模型](#五数据模型)
- [六、核心任务流程](#六核心任务流程)
- [七、交互规则](#七交互规则)
- [八、提醒与通知](#八提醒与通知)
- [九、本地化（中英文）](#九本地化中英文)
- [十、设置项](#十设置项)
- [十一、开发与构建](#十一开发与构建)
- [十二、贡献规范](#十二贡献规范)

---

## 一、项目概览

Liveline 是一个以 **项目（Project）→ 任务（Task）→ 子任务（Subtask）** 为主线的个人任务规划工具。核心使用模型是：

1. 在某个项目下创建任务，可选地设置 **标签、起止日期、优先级、循环规则、提醒**；
2. 在 **任务列表 / 仪表盘 / 日历 / 甘特图** 中查看与组织任务；
3. 在 **全屏详情页（移动端）或桌面右侧详情面板** 中管理任务细节；
4. 通过 **本地通知** 在恰当时间收到提醒，并支持「完成 / 稍后提醒」快捷操作。

应用具备 **响应式布局**，在手机、平板、桌面三种宽度下呈现不同的导航与编辑形态。

### 主要能力

| 能力 | 说明 |
| --- | --- |
| 任务管理 | 创建 / 编辑 / 完成 / 重开 / 软删除，支持批量操作 |
| 项目与标签 | 彩色项目分组、内联创建标签、Inbox 收件箱默认项目 |
| 仪表盘 | 自动按「逾期 / 今天 / 即将到来」分组 |
| 日历视图 | 日 / 周 / 月三种时间粒度 |
| 甘特图 | 一任务一行，拖拽移动 / 缩放 / 重排 |
| 循环任务 | 按日 / 周 / 月 / 自定义间隔自动生成下一实例 |
| 提醒 | 多种相对 / 绝对触发模板，支持免打扰（DND） |
| 全文搜索 | 标题 + 备注 FTS 检索，含 CJK 分词，多维度过滤 |
| 国际化 | 中文 / 英文实时切换 |
| 主题 | 跟随系统 / 浅色 / 深色 |

---

## 二、技术栈

| 领域 | 选型 |
| --- | --- |
| UI 框架 | Flutter（Dart SDK `^3.12.1`），Material 3 |
| 状态管理 / DI | `flutter_riverpod` + `riverpod_annotation` / `riverpod_generator` |
| 路由 | `go_router`（单 `ShellRoute` + 自适应骨架） |
| 本地数据库 | `drift` + `sqlite3_flutter_libs`（SQLite，含 FTS5 全文索引） |
| 不可变模型 | `freezed` + `json_serializable` |
| 本地通知 | `flutter_local_notifications` + `timezone` |
| 设置存储 | `shared_preferences` |
| 桌面窗口 | `window_manager`（Windows 自定义标题栏） |
| 富文本备注 | `flutter_markdown_plus` |
| 字体 | MiSans（内置，统一中英文及 CJK 字形度量） |
| 测试 | `flutter_test` + `mocktail` + `fake_async` + `golden_toolkit` |

---

## 三、信息架构

### 3.1 分层架构（严格单向依赖）

项目遵循 Clean Architecture 风格的分层，依赖方向单向不可逆：

```
presentation ─▶ domain ─▶ core/contracts ◀─ data / platform
```

- **presentation/** — Widget、页面、Notifier（展示状态）。
- **domain/** — 用例（`*UseCase`）、纯逻辑、视图状态。
- **core/contracts/** — 抽象接口（`ITaskRepository`、`INotificationService` 等）。
- **data/** — Drift 数据库具体实现。
- **platform/** — 通知、设置等平台能力具体实现。

> **关键约束：`presentation/` 与 `domain/` 禁止 import `data/` 或 `platform/`**，只能依赖 `core/contracts` 的抽象接口。该约束由 `tool/check_layer_imports.sh` 在 CI 中强制校验。

具体实现在应用启动的「组合根（composition root）」处，通过 Riverpod 的 `overrides` 绑定到抽象接口上。

### 3.2 组合根（`lib/main.dart`）

`main()` 负责装配整个对象图：

1. 初始化 Flutter binding，桌面端初始化 `window_manager`；
2. 注册 MiSans 字体许可；
3. 打开 Drift 数据库 `AppDatabase`；
4. 加载 `SharedPrefsSettingsStore` 设置存储；
5. 按平台创建通知服务 `createPlatformNotificationService()`；
6. 在 `ProviderScope` 中注入所有 `overrides`：

```dart
ProviderScope(
  overrides: [
    ...driftDataLayerOverrides(db),                 // 仓储层
    settingsStoreProvider.overrideWithValue(settings),
    notificationServiceProvider.overrideWithValue(notif),
    syncEngineProvider.overrideWithValue(const NoOpSyncEngine()),
    routerProvider.overrideWithValue(appRouter),
  ],
  child: const NotificationBootstrap(child: LivelineApp()),
)
```

### 3.3 导航与路由

路由集中在 `lib/app.dart`，使用单一 `ShellRoute` 将所有页面包裹进 `AdaptiveScaffold`（自适应骨架），初始路由 `/dashboard`：

| 路由 | 页面 | 说明 |
| --- | --- | --- |
| `/dashboard` | `DashboardPage` | 仪表盘（默认首页） |
| `/projects` | `ProjectsPage` | 项目列表 |
| `/projects/:id` | `ProjectDetailPage` | 项目详情（项目内任务） |
| `/calendar` | `CalendarPage` | 日历 / 甘特图 |
| `/tasks` | 任务入口 | 任务中心 |
| `/tasks/today` | `TaskListPage` | 今天 |
| `/tasks/overdue` | `TaskListPage` | 逾期 |
| `/tasks/completed` | `TaskListPage` | 已完成 |
| `/tasks/tag/:id` | `TaskListPage` | 按标签筛选 |
| `/settings` | `SettingsPage` | 设置 |
| `/task/:id` | `TaskDetailPage` | 任务详情（移动 / 中等布局） |

> 搜索 **不是** 路由，而是通过全局浮层 `search_overlay.dart` 打开。

### 3.4 响应式骨架（`AdaptiveScaffold`）

断点定义于 `lib/core/widgets/layout_breakpoints.dart`：`kCompactBreakpoint = 600`，`kExpandedBreakpoint = 1024`。

| 宽度 | 布局 |
| --- | --- |
| `< 600dp`（手机） | 顶部 AppBar + 底部 `NavigationBar` + 浮动新建按钮（FAB） |
| `600–1024dp`（平板） | 左侧 `NavigationRail` |
| `> 1024dp`（桌面） | 顶栏 + 左侧目录树 + 中部内容 + 右侧任务详情面板 |

任务详情打开行为（`shell_navigation.dart`）：宽屏（≥1024dp）在右侧面板就地打开，窄屏则 `push('/task/:id')` 全屏打开。

---

## 四、目录结构

```text
lib/
├── app.dart                      # 应用根 Widget：主题、本地化、路由
├── main.dart                     # 组合根：ProviderScope overrides
│
├── core/                         # 与业务无关的内核
│   ├── contracts/                # 抽象接口（仓储、通知、设置、同步）
│   ├── di/                       # 抽象 Provider 定义、时钟
│   ├── enums/                    # 全局枚举
│   ├── errors/                   # AppException 体系
│   ├── models/                   # freezed 不可变模型（Task、Project…）
│   ├── theme/                    # 设计系统、间距、圆角、语义色
│   ├── utils/                    # FTS 分词、Result 类型
│   └── widgets/                  # AdaptiveScaffold、AppCard、空状态插画等
│
├── data/                         # Drift 持久化层（实现 contracts）
│   ├── db/                       # 数据库、表、DAO、查询编译器
│   ├── mappers/                  # Row ↔ Model 映射
│   └── repositories/             # DriftXxxRepository
│
├── platform/                     # 平台能力层（实现 contracts）
│   ├── notifications/            # 本地通知（Android / Windows）
│   ├── settings/                 # SharedPreferences 设置存储
│   └── sync/                     # 同步引擎占位（NoOp）
│
├── features/                     # 按功能划分的业务模块
│   ├── dashboard/                # 仪表盘
│   ├── task/                     # 任务（创建/编辑/完成/循环/提醒/子任务）
│   ├── project/                  # 项目 CRUD
│   ├── tag/                      # 标签
│   ├── calendar/                 # 日/周/月/甘特图
│   ├── search/                   # 全文搜索 + 过滤
│   ├── notification/             # 提醒计算与调度
│   └── settings/                 # 设置页
│
└── l10n/                         # 本地化（app_en.arb / app_zh.arb + 生成代码）
```

每个 `features/<feature>/` 内部再分 `domain/`（用例与纯逻辑）与 `presentation/`（页面与 Widget）。

---

## 五、数据模型

模型位于 `lib/core/models/`，均为 `freezed` 不可变类。

### 5.1 Task（任务）

```dart
const factory Task({
  required String id,
  required String title,
  String? notes,                                  // 备注（支持 Markdown）
  String? projectId,
  DateTime? startDate,
  DateTime? dueDate,
  DateTime? createdAt,
  DateTime? completedAt,
  @Default(Priority.medium) Priority priority,
  @Default(TaskStatus.incomplete) TaskStatus status,
  @Default(0) int sortOrder,                       // 列表手动排序
  int? ganttOrder,                                 // 甘特图行排序
  String? recurrenceRuleId,
  String? recurrenceParent,
  @Default(false) bool autoCompleteOnSubtasks,     // 子任务全完成时自动完成父任务
  @Default(<String>[]) List<String> tagIds,
  @Default(<Subtask>[]) List<Subtask> subtasks,
  RecurrenceRule? recurrence,
  // —— 同步预留字段 ——
  DateTime? updatedAt,
  DateTime? deletedAt,                             // 软删除
  @Default(0) int syncVersion,
  String? deviceId,
}) = _Task;
```

派生行为：`statusAt(now)` 计算 `complete / overdue / incomplete`；`subtaskProgress` 计算子任务完成比；`isRecurring` 判断是否循环。

### 5.2 枚举（`lib/core/enums/`）

| 枚举 | 取值 |
| --- | --- |
| `Priority` | `high`, `medium`, `low`（索引越小优先级越高） |
| `TaskStatus` | `incomplete`, `complete`, `overdue`（逾期为运行时派生，不入库） |
| `ReminderType` | `beforeDue`, `atStart`, `custom`, `overdue` |
| `RecurrenceFrequency` | `daily`, `weekly`, `monthly`, `custom` |
| `CalendarViewType` | `day`, `week`, `month`, `gantt` |
| `TaskSort` | `dueDate`, `priority`, `createdAt`, `dueAsc/Desc`, `priorityDesc`, `createdDesc`, `manual` |
| `StatusFilter` | `all`, `incomplete`, `complete`, `overdue` |
| `ProjectDeleteMode` | 删除项目时：移动任务到 Inbox / 一并删除任务 |
| `SyncStatus` | `idle`, `syncing`, `success`, `error` |

### 5.3 其他模型

- **Project**：`id`、`name`、`color`、`sortOrder`、时间戳、同步字段。
- **Tag**：`id`、`name`、`color`。
- **Subtask**：`id`、`title`、`isDone`、`sortOrder`。
- **Reminder**：`id`、`taskId`、`triggerAt`、`type`、`offsetMin`、`isFired`、`notifId`。
- **RecurrenceRule**：`frequency`、`interval`、`byWeekday`（ISO 周一=1…周日=7）、`byMonthDay`、`endDate`、`count`。
- **AppSettings**：`notificationsEnabled`、`defaultReminderMinutes`、`themeMode`、`locale`、`dashboardUpcomingDays`。

### 5.4 数据库（Drift / SQLite）

数据库定义于 `lib/data/db/app_database.dart`，Schema 版本 `2`，文件名 `liveline.sqlite`（位于应用文档目录）。

注册的表：`Projects`、`Tasks`、`Subtasks`、`Tags`、`TaskTags`（多对多连接表）、`Reminders`、`RecurrenceRules`。

要点：

- 启动时开启外键约束，并种入默认项目 `inbox`（"Inbox / 收件箱"）；
- 为任务的 due/start/completion/project/deleted 等字段建立索引；
- 建立 FTS5 虚拟表 `tasks_fts` 对 `tasks(title, notes)` 做全文索引，并用触发器保持同步；
- 表级约束 `due_date >= start_date`（截止不得早于开始）。

DAO：`TaskDao`、`ProjectDao`、`TagDao`、`ReminderDao`，外加用于搜索的 `TaskQueryCompiler`。

---

## 六、核心任务流程

业务逻辑全部封装在 `domain/` 的用例中，通过 Riverpod Provider 暴露，Widget 不直接调用仓储。

### 6.1 创建任务

入口：

- 全局 FAB → `AddTaskSheet`（底部弹层）；
- 桌面任务列表顶部 `QuickAddBar`（仅标题快速创建）；
- 日历 / 甘特图空白处点击（预填起止日期）；
- 项目 / 标签作用域列表（预填项目 / 标签）。

流程：`CreateTaskUseCase` → `TaskValidator` 校验 → 仓储写入 → `ReminderScheduler.sync(task)` 同步提醒。

校验规则（`task_validator.dart`）：

```dart
if (draft.title.trim().isEmpty) {
  return const Err(ValidationException(code: 'emptyTitle', ...));
}
if (draft.dueDate != null && draft.startDate != null &&
    draft.dueDate!.isBefore(draft.startDate!)) {
  // 截止日期不得早于开始日期
}
```

### 6.2 编辑任务

详情页（`task_detail_body.dart`）可编辑：标题、备注（Markdown 编辑 / 预览）、起止日期、优先级、标签、循环规则、提醒、子任务、「子任务完成自动完成」开关。`UpdateTaskUseCase` 校验后更新并重新调度提醒。

### 6.3 完成 / 重开 / 删除

- **完成**：勾选复选框或左右滑动。`CompleteTaskUseCase` 标记完成 → 取消该任务通知 → 若为循环任务，向 `RecurrenceEngine` 请求下一实例并创建、复制提醒配置、重新调度。
- **重开**：`UncompleteTaskUseCase` 重新打开已完成任务。
- **删除**：软删除（写 `deletedAt`），同时取消通知。循环任务可选「删除单个实例」或「删除整个系列」。
- **批量**：长按任务行进入多选模式，批量完成 / 删除。

### 6.4 循环任务生成

`RecurrenceEngine.nextInstance(task, after: now)` 为纯函数，根据 `RecurrenceRule` 计算下一次发生时间；当任务被完成时才生成下一实例。

> 说明：模型中保留了 `count`（最大发生次数）字段，但当前选择器 UI 仅暴露 `endDate`，引擎也只依据 `endDate` 终止。

---

## 七、交互规则

### 7.1 日历视图

- **日 / 周 / 月** 三种粒度切换，附「上一页 / 今天 / 下一页」控制。
- **日视图**：含全天事件带 + 24 小时纵向网格 + 重叠布局；长按某时间点创建定时任务；可将全天任务拖入网格；侧滑面板可「快速排布」未排期任务。
- **周视图**：7 列定时网格；点击列头进入日视图；长按创建定时任务；右键提供「创建 / 打开当日」。
- **月视图**：日期格内可滚动的迷你任务条；点击空白格进入当日；任务块可在日期间拖拽。

### 7.2 甘特图（`gantt_view.dart`）

- **一任务一行**，仅显示设置了日期的任务；
- 行序按 `ganttOrder`，其次按创建时间；
- 头部与各行 **横向滚动同步**；
- 桌面：空白处点击在当日创建任务，右键任务条弹出「编辑 / 删除」；移动端：长按空白处创建；
- 拖拽 **行标签** 上下重排（持久化到 `ganttOrder`）；
- 拖拽 **条体** 整体移动日期范围；拖拽 **条两端** 调整起止；
- 拖拽 **按整天吸附**；
- 非法操作（移动 / 缩放导致截止早于开始）会被丢弃（`gantt_interaction_controller.dart`）。

### 7.3 通用业务规则

- 既无开始也无截止日期的任务 **不出现在日历 / 甘特图**，但会出现在日视图的「快速排布」面板中。
- 时间为 **午夜（00:00）视为全天任务**。
- 定时网格创建 / 拖放按 **15 分钟** 吸附。
- 任务条颜色可按 **优先级** 或 **项目** 着色（项目模式：项目色相 + 优先级饱和度）；已完成 / 逾期任务条变淡。
- 删除项目时可选「任务移至 Inbox」或「一并删除任务」；**Inbox 不可从 UI 删除**。
- 标签在数据库层唯一，可在任务详情中内联创建。
- 仅当开启 `autoCompleteOnSubtasks` 时，子任务全部完成才会自动完成父任务。
- 任务查询窗口使用 **区间重叠** 逻辑，而非简单包含。

---

## 八、提醒与通知

### 8.1 提醒模板

在任务详情的「提醒编辑」对话框（`reminders_editor_dialog.dart`）中可添加：

- 到截止时间提醒；
- 截止前 5 / 10 / 15 / 30 / 60 分钟；
- 截止前 1 天；
- 自定义「截止前 N 分钟」；
- 到开始时间提醒；
- 任务无起止日期时不可设置提醒。

### 8.2 调度（`ReminderScheduler`）

- 创建 / 更新任务时调用 `scheduler.sync(task)`；
- 完成任务时取消其通知；
- 全局通知开关可整体禁用调度；
- **免打扰（DND）**：在配置时间段内抑制非逾期通知，时间段可跨午夜（如 22:00–08:00）；
- 启动时执行对账，补排未来 30 天内丢失的待发提醒；
- Android 通知带「Mark done（完成）」「Snooze 15m（稍后 15 分钟）」动作；
- 点击 / 打开通知跳转至 `/task/:id`。

### 8.3 平台实现

通知服务通过工厂 `createPlatformNotificationService()` 按平台选择：

- `FlutterLocalNotificationService`：基于 `flutter_local_notifications` + `timezone`，处理 Android/Windows 初始化、权限、精确闹钟、动作按钮；
- `WindowsNotificationService`：测试 / 占位实现，记录调度与取消，不弹真实系统通知。

---

## 九、本地化（中英文）

应用支持 **英文（en）** 与 **中文（zh）**，可在设置中实时切换，由 `localeProvider` 驱动 `MaterialApp.router` 的 `locale`。

文案分别维护于 `lib/l10n/app_en.arb` 与 `lib/l10n/app_zh.arb`，通过 `flutter gen-l10n` 生成 `AppLocalizations`。

> **强制约定**：所有面向用户的字符串必须经由 `AppLocalizations`，并 **同时** 在 `app_en.arb` 和 `app_zh.arb` 中添加对应键（两者键集必须保持一致），然后重新生成。禁止硬编码可见文案。

```dart
// 错误：硬编码，破坏中英文切换
Text('No tasks')

// 正确
Text(AppLocalizations.of(context)!.emptyTasks)
```

文案覆盖范围：导航与窗口、任务创建 / 列表 / 详情、日历与甘特、搜索过滤、设置、项目与标签、错误提示等。

---

## 十、设置项

设置页（`settings_page.dart`）按以下分类组织（桌面为主从布局）：

| 分类 | 内容 |
| --- | --- |
| 外观 Appearance | 主题（系统 / 浅色 / 深色）、甘特条颜色（优先级 / 项目）、默认日历视图、语言（中文 / 英文） |
| 通知 Notifications | 全局开关、默认提前提醒分钟数、逾期重复提醒小时数 |
| 免打扰 DND | 开关、开始时间、结束时间 |
| 仪表盘 Dashboard | 「即将到来」窗口天数 |
| 同步 Sync | 云同步占位（暂未实现，使用 `NoOpSyncEngine`） |
| 关于 About | 版本、隐私政策占位、字体、开源许可 |

持久化键定义于 `lib/core/models/setting_keys.dart`（如 `themeMode`、`locale`、`dndEnabled`、`barColorMode`、`defaultCalendarView` 等），通过 `SharedPreferences` 存储。

---

## 十一、开发与构建

### 11.1 环境要求

- Flutter SDK，Dart `^3.12.1`
- 目标平台：Android、Windows 桌面

### 11.2 常用命令

```bash
flutter pub get

# 代码生成（drift / freezed / riverpod）
dart run build_runner build --delete-conflicting-outputs

# 重新生成本地化
flutter gen-l10n

# 格式化与静态分析
dart format .
flutter analyze

# 分层 import 校验
bash tool/check_layer_imports.sh

# 测试与覆盖率
flutter test --coverage
dart run tool/check_coverage.dart coverage/lcov.info
```

> `*.g.dart` / `*.freezed.dart` 为生成文件，**切勿手改**，请运行代码生成。

### 11.3 发布构建

在 Windows 主机上使用 `tool/build.ps1`（sqlite3 原生库、Android SDK、Windows AOT 等细节见 `tool/build.md`）：

```powershell
pwsh tool/build.ps1                  # 同时构建 Windows + Android Release
pwsh tool/build.ps1 -Target windows  # 仅构建 Windows
```

---

## 十二、贡献规范

每个新功能或行为变更 **必须** 满足以下三点（详见 `.cursor/rules/feature-conventions.mdc`）：

1. **l10n** — 无硬编码可见文案；键同时加入 `app_en.arb` 与 `app_zh.arb` 并重新生成。
2. **usecase** — 触达数据的逻辑放在 `domain/` 下的 `*UseCase`，经 Riverpod Provider 暴露；Widget 不直接调用仓储 / 服务。
3. **test** — 用例 / Notifier / 纯逻辑写单元测试（`test/unit/...`），页面 / Widget 写 Widget 测试（必要时含 golden，`test/widget/...`），目录结构镜像 `lib/`。

覆盖率阈值（`tool/check_coverage.dart`）：domain ≥ 90%，data ≥ 80%。

并请遵守分层约束：`presentation/` 与 `domain/` 不得 import `data/` 或 `platform/`。
