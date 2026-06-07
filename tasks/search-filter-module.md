# 搜索与筛选模块任务清单 / Search & Filter Module Tasks

> Source: `design/04-search-filter-module.md`  
> Depends on: `tasks/architecture-overview.md`, `tasks/data-and-persistence.md`, `tasks/task-module.md`  
> Status: Complete

## 目标 / Goal

实现统一 `TaskQuery` 查询规格、全文搜索、日期/状态/优先级/标签/项目筛选、查询编译器、防抖与搜索 UI。

## Checklist

- [x] 创建 `TaskQuery` 模型，包含 keyword、dateFilter、status、priorities、tagIds、projectIds、sort、includeCompleted、includeDeleted。
- [x] 创建 `DateFilter` sealed/freezed 类型：on / range / overlap。
- [x] 创建 `StatusFilter` 枚举：all / incomplete / complete / overdue。
- [x] 创建 `TaskSort` 枚举：dueAsc / dueDesc / priorityDesc / createdDesc / manual。
- [x] 实现 `TaskQuery.rangeOverlap()` 工厂方法，供日历与甘特复用。
- [x] 在数据层实现 `TaskQueryCompiler`。
- [x] 实现软删除默认过滤：`deleted_at IS NULL`。
- [x] 实现状态筛选编译：未完成、已完成、逾期、全部。
- [x] 实现优先级筛选编译。
- [x] 实现项目筛选编译。
- [x] 实现标签筛选编译，使用 `EXISTS` 或 join。
- [x] 实现日期筛选编译：单日、范围、区间交集。
- [x] 实现排序编译：截止日期、优先级、创建时间、手动排序。
- [x] 实现 FTS rowid 约束与普通筛选组合。
- [x] 实现 `buildFtsMatch()`。
- [x] 实现中英文分段 `_splitByScript()`。
- [x] 实现中文 2-gram 分词。
- [x] 实现英文前缀匹配 token。
- [x] 实现搜索结果关键词高亮策略。
- [x] 创建 `SearchController` Provider。
- [x] 实现 250ms 输入防抖。
- [x] 实现筛选条件更新方法：状态、标签、项目、优先级、日期、清空。
- [x] 创建 `searchResultsProvider`，将任务映射为 `TaskView`。
- [x] 创建 `SearchPage`。
- [x] 创建 `SearchBar`。
- [x] 创建 `FilterChipsRow`，支持状态/优先级/标签/项目/日期筛选。
- [x] 创建 `DateFilterSheet`，支持今天、本周、本月、自定义范围。
- [x] 创建 `ResultList`，复用 `TaskTile`。
- [x] 创建 `EmptyState`。

## 验收标准 / Acceptance Criteria

- [x] 用户输入关键词后结果实时更新。
- [x] 标题与备注均可被全文搜索命中。
- [x] 搜索和所有筛选条件按 AND 逻辑组合。
- [x] 日期、状态、优先级、标签、项目筛选均有效。
- [x] 无结果时展示空状态。
- [x] 查询响应满足需求目标：输入后约 300ms 内返回。

## 测试 / Tests

- [x] `TaskQueryCompiler` 各筛选维度测试。
- [x] keyword + status + tag 组合 AND 测试。
- [x] 中文 2-gram 分词测试。
- [x] 中英混合关键词测试。
- [x] 防抖测试：连续输入只触发一次更新。
- [x] 空状态 widget 测试。
- [x] Filter chips 多选刷新结果测试。
