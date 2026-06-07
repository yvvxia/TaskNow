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
  String get emptyTaskList => '暂无任务';

  @override
  String get createAction => '创建';

  @override
  String get taskPriority => '优先级';

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
}
