# 04 · 搜索与筛选模块 / Search & Filter Module

> 关联 / Related: [README](README.md) · [01 数据](01-data-and-persistence.md) · [需求 §3.3](../doc/proposal.md)

---

## 1. 职责 / Responsibility

**中文：** 提供统一的查询规格 `TaskQuery`，承载全文搜索 + 多维筛选（日期、状态、优先级、标签、项目）的组合条件；将规格编译为 SQL/Drift 查询；负责输入防抖、关键词高亮、空状态。`TaskQuery` 是本模块定义、被 01/02/03 复用的核心契约。

**English:** Defines a unified `TaskQuery` spec carrying full-text search + multi-dimensional filters (date, status, priority, tags, project); compiles the spec into Drift SQL; handles debounce, keyword highlight, empty state. `TaskQuery` is the shared contract reused by modules 01/02/03.

---

## 2. 查询规格 / Query Spec (核心契约 / core contract)

```dart
// core/contracts/task_query.dart
@freezed
class TaskQuery with _$TaskQuery {
  const factory TaskQuery({
    String? keyword,                      // 全文：title + notes
    DateFilter? dateFilter,               // 日期范围
    @Default(StatusFilter.all) StatusFilter status,
    Set<Priority>? priorities,            // null/empty = 全部
    @Default(<String>{}) Set<String> tagIds,
    @Default(<String>{}) Set<String> projectIds,
    @Default(TaskSort.dueAsc) TaskSort sort,
    @Default(false) bool includeCompleted,
    @Default(false) bool includeDeleted,  // 始终 false（软删除隐藏）
  }) = _TaskQuery;

  /// 区间重叠（日历/甘特用）/ for calendar range
  factory TaskQuery.rangeOverlap(DateTimeRange r) =>
      TaskQuery(dateFilter: DateFilter.overlap(r), includeCompleted: true);
}

@freezed
class DateFilter with _$DateFilter {
  const factory DateFilter.on(DateTime day) = _DateOn;        // 今天/某日
  const factory DateFilter.range(DateTimeRange r) = _DateRange; // 自定义/本周/本月
  const factory DateFilter.overlap(DateTimeRange r) = _DateOverlap; // 与区间相交
}

enum StatusFilter { all, incomplete, complete, overdue }
enum TaskSort { dueAsc, dueDesc, priorityDesc, createdDesc, manual }
```

> **设计要点 / Key:** `TaskQuery` 放在 `core/contracts`，使任务清单（02）、日历（03）、搜索（04）共用同一查询语言，避免每个模块各写 SQL。

---

## 3. 查询编译器 / Query Compiler

**中文：** 将 `TaskQuery` 编译为 Drift `Selectable`。非全文条件用 Drift 表达式；含 `keyword` 时先走 FTS 取候选 rowid，再叠加筛选。

```dart
// data/db/task_query_compiler.dart
class TaskQueryCompiler {
  TaskQueryCompiler(this._db);
  final AppDatabase _db;

  Selectable<TaskRow> compile(TaskQuery q) {
    final query = _db.select(_db.tasks);

    query.where((t) => t.deletedAt.isNull());

    // 状态 / status
    switch (q.status) {
      case StatusFilter.incomplete:
        query.where((t) => t.isCompleted.equals(false));
      case StatusFilter.complete:
        query.where((t) => t.isCompleted.equals(true));
      case StatusFilter.overdue:
        final now = DateTime.now().msUtc;
        query.where((t) =>
            t.isCompleted.equals(false) &
            t.dueDate.isNotNull() &
            t.dueDate.isSmallerThanValue(now));
      case StatusFilter.all:
        if (!q.includeCompleted) query.where((t) => t.isCompleted.equals(false));
    }

    // 优先级 / priority
    if (q.priorities != null && q.priorities!.isNotEmpty) {
      query.where((t) => t.priority.isIn(q.priorities!.map((p) => p.index)));
    }

    // 项目 / project
    if (q.projectIds.isNotEmpty) {
      query.where((t) => t.projectId.isIn(q.projectIds));
    }

    // 日期 / date
    _applyDate(query, q.dateFilter);

    // 标签 / tags (子查询 EXISTS)
    if (q.tagIds.isNotEmpty) {
      query.where((t) => existsQuery(_tagSubquery(t.id, q.tagIds)));
    }

    // 关键词 / keyword (FTS rowid 约束)
    if (q.keyword != null && q.keyword!.trim().isNotEmpty) {
      final ids = _ftsRowIds(q.keyword!);
      query.where((t) => t.rowId.isIn(ids));
    }

    _applySort(query, q.sort);
    return query;
  }
}
```

---

## 4. 全文搜索与中文分词 / FTS & CJK Tokenization

**中文：** FTS5 默认对中文不分词。Phase 1 在查询层做 **2-gram** 处理：把中文关键词拆成相邻二元组，用 `OR`（FTS5 中空格即 AND，故用显式 `OR`）或 `AND` 组合；西文按词处理。

```dart
String buildFtsMatch(String raw) {
  final tokens = <String>[];
  for (final segment in _splitByScript(raw)) {     // 按中/英分段
    if (segment.isCjk) {
      // “需求文档” -> 需求 求文 文档
      for (var i = 0; i < segment.text.length - 1; i++) {
        tokens.add('"${segment.text.substring(i, i + 2)}"');
      }
    } else {
      tokens.add('${segment.text}*');              // 前缀匹配
    }
  }
  return tokens.join(' AND ');                      // 全部命中
}
```

- 高亮 / Highlight：用 FTS5 `snippet()`/`highlight()` 或在 UI 层对原文做关键词标记。
- 排序 / Ranking：FTS5 内置 `rank`（BM25）。
- 升级路径 / Upgrade：若 2-gram 召回/精度不足，Phase 2 接入 ICU 或 `simple` tokenizer（带拼音）。

---

## 5. 状态管理与防抖 / State & Debounce

```dart
@riverpod
class SearchController extends _$SearchController {
  Timer? _debounce;

  @override
  TaskQuery build() => const TaskQuery(); // 初始空查询

  void setKeyword(String kw) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      state = state.copyWith(keyword: kw);   // 250ms 防抖 -> 满足 <300ms 验收
    });
  }

  void setStatus(StatusFilter s) => state = state.copyWith(status: s);
  void toggleTag(String id) => state = state.copyWith(tagIds: state.tagIds.xor(id));
  void setPriorities(Set<Priority> p) => state = state.copyWith(priorities: p);
  void setDate(DateFilter? f) => state = state.copyWith(dateFilter: f);
  void clear() => state = const TaskQuery();
}

@riverpod
Stream<List<TaskView>> searchResults(SearchResultsRef ref) {
  final query = ref.watch(searchControllerProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final now = ref.watch(clockProvider);
  return repo.watch(query).map((ts) => ts.map((t) => TaskView.from(t, now)).toList());
}
```

---

## 6. UI 结构 / UI Structure

| 组件 / Widget | 说明 / Notes |
|---|---|
| `SearchBar` | 顶部输入框，实时（防抖）触发 |
| `FilterChipsRow` | 状态/优先级/标签/日期 chips（多选）；对应需求移动端搜索页 |
| `DateFilterSheet` | 今天 / 本周 / 本月 / 自定义范围 |
| `ResultList` | 复用 02 的 `TaskTile`，关键词高亮 |
| `EmptyState` | 无结果友好提示（需求 §3.3.3 验收） |

**组合逻辑 / Combination:** 搜索关键词与所有筛选 **AND** 组合（需求 §3.3.2）。不提供保存的智能清单（明确排除）。

---

## 7. 测试策略 / Testing

| 层 / Layer | 测试 / Tests |
|---|---|
| 编译器 / Compiler | 各筛选维度生成正确结果（内存库 seed 后断言返回集） |
| 组合 / Combination | keyword + status + tag 同时生效（AND） |
| 分词 / Tokenizer | `buildFtsMatch('需求文档')` 产出预期 2-gram；中英混合 |
| 防抖 / Debounce | 连续输入只触发一次查询（FakeAsync） |
| Widget | 空状态展示；chip 多选刷新结果 |

```dart
test('keyword + overdue status combine with AND', () async {
  final db = newTestDb();
  await seedTasks(db, [overdueMatch, overdueNoMatch, doneMatch]);
  final repo = DriftTaskRepository(db);
  final res = await repo.query(const TaskQuery(keyword: '报告', status: StatusFilter.overdue));
  expect((res as Ok).value, [overdueMatch]);
});
```
