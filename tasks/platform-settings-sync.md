# 平台 / 设置 / 国际�?/ 同步预留任务清单

> Source: `design/06-platform-settings-sync.md`  
> Depends on: `tasks/architecture-overview.md`, `tasks/notification-module.md`  
> Status: Complete

## 目标 / Goal

实现跨模块横切能力：应用设置、主题、国际化、平台服务抽象、启动序列，以及 Phase 2 云同步预留接口�?
## Checklist

- [x] 创建 `AppSettings` 不可变模型�?- [x] 创建设置相关值对象：`TimeOfDayData`、`ThemeModeData`、`LocaleData`、`BarColorMode`�?- [x] 定义默认设置：通知开启、提�?15 分钟、逾期 24 小时重复、DND 默认关闭、系统主题、优先级配色、系统语言、周视图默认日历�?- [x] 定义 `ISettingsStore` 接口�?- [x] 实现 `SharedPrefsSettingsStore`，使�?JSON 持久化�?- [x] 实现 `current`、`update()`、`watch()`�?- [x] 设置变化后能驱动主题、语言和通知重排�?- [x] 实现 `appLightThemeProvider` �?`appDarkThemeProvider`�?- [x] 使用 Material 3 �?seed color 生成主题�?- [x] 创建 `semantic_colors.dart`，集中定义优先级、逾期、完成、主色等语义色�?- [x] 配置 Flutter `gen-l10n`�?- [x] 创建 `l10n.yaml`�?- [x] 创建 `app_zh.arb`�?- [x] 创建 `app_en.arb`�?- [x] 将领域错�?`messageKey` 映射�?i18n 文案�?- [x] 实现本地化日�?时间格式工具�?- [x] 定义 `ILayoutInfo` 接口�?- [x] 实现 compact / medium / expanded 断点判断�?- [x] 定义 `IFileService` 接口�?- [x] 实现 Android 数据库路径�?- [x] 实现 Windows 数据库路径�?- [x] 定义 `IBackgroundScheduler` 接口�?- [x] Android 接入 WorkManager 或预留适配器�?- [x] Windows 实现启动对账型后台策略�?- [x] 定义 `ISyncEngine` 接口：push / pull / fullSync / status�?- [x] 定义 `IAuthService` 接口：signIn / signOut / authState�?- [x] 创建 Phase 1 `NoOpSyncEngine`�?- [x] 创建游客模式与登录模式的状态模型占位�?- [x] �?`main()` 启动流程中接入：打开数据�?-> 加载设置 -> 初始化通知 -> 通知对账 -> DI 装配 -> runApp�?- [x] 创建设置�?UI：通知开关、默认提前量、逾期间隔、DND、主题、语言、甘特条配色�?
## 验收标准 / Acceptance Criteria

- [x] 设置可持久化并在重启后恢复�?- [x] 设置变化能通过 `watch()` 推送�?- [x] 主题可在浅色、深色、跟随系统之间切换�?- [x] 中英文基础文案可切换�?- [x] 数据库路径在 Windows �?Android 上由平台服务提供�?- [x] Phase 1 同步引擎为空实现且不会影响本地使用�?- [x] 应用启动序列可顺利完成并进入主界面�?
## 测试 / Tests

- [x] `SharedPrefsSettingsStore` 默认值测试�?- [x] `update()` 持久化与 `watch()` 推送测试�?- [x] 主题生成测试�?- [x] ARB key 完整性测试�?- [x] 断点判断测试�?- [x] `NoOpSyncEngine` 不报错测试�?
