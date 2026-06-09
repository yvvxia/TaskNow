// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navTasks => '任务';

  @override
  String get navDashboard => '概览';

  @override
  String get navProjects => '项目';

  @override
  String get navCalendar => '日历';

  @override
  String get navSearch => '搜索';

  @override
  String get navSettings => '设置';

  @override
  String get tasksTitle => '任务';

  @override
  String get addTaskHint => '添加任务…（按回车）';

  @override
  String get newTaskTitle => '任务标题';

  @override
  String get taskStartDate => '开始日期';

  @override
  String get taskDueDate => '截止日期';

  @override
  String get dateNotSet => '未设置';

  @override
  String get dateClear => '清除';

  @override
  String get allDay => '全天';

  @override
  String get clearTime => '清除时间（全天）';

  @override
  String get newTaskWithTime => '新建任务（含日期时间）';

  @override
  String get emptyTaskList => '暂无任务';

  @override
  String get createAction => '创建';

  @override
  String get taskPriority => '优先级';

  @override
  String get calendarPrevious => '上一个';

  @override
  String get calendarNext => '下一个';

  @override
  String get calendarToday => '今天';

  @override
  String get calendarDay => '日';

  @override
  String get calendarWeek => '周';

  @override
  String get calendarMonth => '月';

  @override
  String get calendarGantt => '甘特图';

  @override
  String calendarLoadError(String message) {
    return '加载失败：$message';
  }

  @override
  String calendarWeekTaskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '本周 $count 个任务',
      zero: '本周暂无任务',
    );
    return '$_temp0';
  }

  @override
  String calendarMoreTasks(int count) {
    return '还有 $count 个';
  }

  @override
  String get searchHint => '搜索任务…';

  @override
  String get searchNoResults => '没有匹配的任务';

  @override
  String get searchTryDifferentFilters => '试试其他关键词或筛选条件';

  @override
  String searchFailed(String message) {
    return '搜索失败：$message';
  }

  @override
  String get searchClearFilters => '清除';

  @override
  String get searchDateFilter => '日期';

  @override
  String get searchDateToday => '今天';

  @override
  String get searchDateThisWeek => '本周';

  @override
  String get searchDateThisMonth => '本月';

  @override
  String get searchDateCustomRange => '自定义范围';

  @override
  String get searchDateClearFilter => '清除日期筛选';

  @override
  String searchDateOverlap(String range) {
    return '重叠 $range';
  }

  @override
  String get searchStatusAll => '全部';

  @override
  String get searchStatusIncomplete => '未完成';

  @override
  String get searchStatusDone => '已完成';

  @override
  String get searchStatusOverdue => '已逾期';

  @override
  String get searchPriorityHigh => '高';

  @override
  String get searchPriorityMedium => '中';

  @override
  String get searchPriorityLow => '低';

  @override
  String get settingsTitle => '设置';

  @override
  String get appearanceSection => '外观';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get languageSection => '语言';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get notificationsSection => '通知';

  @override
  String get notificationsGlobal => '启用通知';

  @override
  String get notificationsDefaultReminder => '默认提醒时间';

  @override
  String notificationsDefaultReminderValue(int minutes) {
    return '提前 $minutes 分钟';
  }

  @override
  String get notificationsOverdueRepeat => '逾期重复间隔';

  @override
  String notificationsOverdueRepeatValue(int hours) {
    return '每 $hours 小时';
  }

  @override
  String get dndSection => '免打扰';

  @override
  String get dndEnabled => '启用免打扰';

  @override
  String get dndStart => '开始时间';

  @override
  String get dndEnd => '结束时间';

  @override
  String get syncSection => '云同步';

  @override
  String get syncComingSoon => '云同步 — 即将在第二阶段推出';

  @override
  String get aboutSection => '关于';

  @override
  String aboutVersion(String version) {
    return '版本 $version';
  }

  @override
  String get aboutPrivacy => '隐私政策';

  @override
  String get aboutOpenSource => '开源许可';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '删除';

  @override
  String get actionComplete => '完成';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionAdd => '添加';

  @override
  String get deleteTaskTitle => '删除任务？';

  @override
  String deleteTaskMessage(String title) {
    return '将永久删除“$title”。';
  }

  @override
  String get deleteTaskGenericMessage => '将永久删除该任务。';

  @override
  String get errorEmptyTitle => '标题不能为空';

  @override
  String get errorDueBeforeStart => '截止日期不能早于开始日期';

  @override
  String get errorInvalidReminder => '无效的提醒时间';

  @override
  String get errorNotFound => '未找到该项目';

  @override
  String get errorPersistence => '保存数据失败';

  @override
  String get errorPermission => '权限被拒绝';

  @override
  String get minutesDialog => '设置提醒提前时间（分钟）';

  @override
  String get hoursDialog => '设置逾期重复间隔（小时）';

  @override
  String get projectLabel => '项目';

  @override
  String get calendarCreateTaskHere => '创建任务';

  @override
  String get calendarOpenDay => '打开当天';

  @override
  String get dashboardEmpty => '没有待办，一切就绪！';

  @override
  String get dashboardSectionEmpty => '暂无内容';

  @override
  String get dashboardOverdue => '已逾期';

  @override
  String get dashboardToday => '今天';

  @override
  String dashboardUpcoming(int days) {
    return '即将截止（$days 天内）';
  }

  @override
  String get dashboardUpcomingDaysSetting => '即将截止范围';

  @override
  String dashboardUpcomingDaysValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days 天',
      one: '1 天',
    );
    return '$_temp0';
  }

  @override
  String get dashboardUpcomingDaysDialog => '即将截止范围（天）';

  @override
  String get projectsEmpty => '还没有项目，点击 + 新建。';

  @override
  String get projectCreateTitle => '新建项目';

  @override
  String get projectEditTitle => '编辑项目';

  @override
  String get projectNameLabel => '项目名称';

  @override
  String get projectColorLabel => '颜色';

  @override
  String get projectDeleteTitle => '删除项目？';

  @override
  String projectDeleteMessage(String name) {
    return '“$name”中的任务如何处理？';
  }

  @override
  String get projectDeleteMoveInbox => '移至收件箱';

  @override
  String get projectDeleteWithTasks => '连同任务删除';

  @override
  String get projectTabList => '列表';

  @override
  String get projectTabCalendar => '日历';

  @override
  String get projectTabGantt => '甘特图';

  @override
  String get errorEmptyProjectName => '项目名称不能为空';
}
