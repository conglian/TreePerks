import 'TPPaymentConfig.dart';
import 'TPLogger.dart';
import 'package:flutter/foundation.dart';
// TODO: 配套源码尚未接入。
// import 'package:treeperks/TPHome/TPHome.dart';
import 'package:treeperks/TPTool/TPNumberHelpers.dart';
import 'package:treeperks/TPTool/TPTBAEventTool.dart';
import 'package:treeperks/TPTool/TPExtensionHelp.dart';
import 'package:shared_preferences/shared_preferences.dart';
// TODO: 配套源码尚未接入。
// import '../TPBase/TPTbaBar.dart';
// TODO: 配套源码尚未接入。
// import '../TPDialog/TPDialog.dart';
// TODO: 配套源码尚未接入。
// import '../TPPigVC/TPPigCash.dart';
// TODO: 配套源码尚未接入。
// import '../TPPigVC/TPPigHome.dart';

class TPLocalProvider extends ChangeNotifier {
  // 1. 私有构造函数（禁止外部直接创建实例）
  TPLocalProvider._();

  // 2. 静态单例实例
  static final TPLocalProvider _instance = TPLocalProvider._();

  // 3. 提供全局访问点
  static TPLocalProvider get instance => _instance;

  final TPThresholdTrigger _trigger = TPThresholdTrigger();
  Future<void>? _triggerInitialization;

  // SJTXModel txEntity = SJTXModel();

  String tp_account_id = '';
  String tp_tx_list = "";
  String tp_ratio_str = "90";

  bool tp_bg_music = true; // 存储的本地值
  bool tp_sound_music = true; // 存储的本地值
  bool tp_login_status = false; // 存储的本地值
  bool tp_scratch_status_0 = true;
  bool tp_scratch_status_1 = true;
  bool tp_scratch_status_2 = true;
  bool tp_scratch_status_3 = true;
  bool tp_scratch_status_4 = true;
  bool tp_scratch_status_5 = true;
  bool tp_scratch_status_6 = true;
  bool tp_scratch_status_7 = true;
  bool tp_scratch_status_8 = true;
  bool tp_scratch_guide = true;
  bool tp_old_guide = true;
  bool tp_new_guide = false;
  bool is_end_Scratch = true;
  bool tp_show_dolas_ani = false;
  bool tp_show_bubble = false;
  bool tp_show_box_guide = false;
  bool tp_cloak_status = false;
  bool tp_fk_number_status = false;
  bool tp_fk_decvice_status = false;
  bool tp_fk_ip_status = false;
  bool tp_fk_ad_short_show = false;
  bool tp_fk_ad_short_close = false;
  bool tp_dolas_800 = false;
  bool tp_dolas_1000 = false;
  bool tp_yunying_3 = false;
  bool tp_yunying_1 = false;
  bool tp_100_timer_star = false;
  bool tp_txing_status = false;
  bool tp_tx_first_status = false;
  bool tp_tx_last_status = false;
  bool tp_show_box_tips = false;
  bool tp_first_box_tips = false;
  bool tp_first_show_cash = false;
  bool tp_open_tx = false;
  bool tp_tx_task2_tips = false;
  bool tp_last_tx_end = false;
  bool tp_show_box = false;
  bool tp_tx_task3_tips = false;
  bool tp_tx_task4_tips = false;
  bool tp_tx_end_status = false;
  bool tp_afSwitch = true;
  bool tp_set_root = false;
  bool tp_af_status = false;
  bool tp_newA_guide = false;
  bool tp_good_review_status = false;
  bool tp_show_80_pop = false;
  bool tp_show_rank = false;
  bool tp_tx_ing_status = false;
  bool tp_install_status = false;

  int tp_scrach_unlock_index_0 = 0; // 存储的本地值
  int tp_scrach_unlock_index_1 = 0; // 存储的本地值
  int tp_ad_all_number = 0;
  double tp_dolas_number = 0.00;
  double tp_dolas_old_number = 0.0;
  double add_olduser_point = 0.03;
  int tp_ad_reawrd_all_number = 0;
  int tp_ad_short_show_number = 0;
  int tp_ad_short_close_number = 0;
  int tp_ad_show_index = 0;
  int tp_ad_show_number = 0;
  int tp_key_number = 0;
  int tp_account_seled_index = 0;
  int tp_tx_ing_account = 0;
  int tp_tx_ing_number = 0;
  int tp_tx_task_index = 0;
  int tp_current_ranking = 99;
  int tp_all_ranking = 388;
  int tp_rank_ad_count = 0;
  int tp_tx_card_index = 0;
  int tp_tx_wheel_index = 0;
  int tp_tx_bubble_index = 0;
  int tp_tx_quiz_index = 0;
  int tp_box_index = 0;
  int tp_card_number = 0;
  int tp_Level_number = 1; // 存储的本地值
  int tp_Level_inedx = 1; // 存储的本地值
  int tp_dice_number = 0;
  int tp_card_a_number = 0;
  int tp_scrach_end_number_0 = 0; // 存储的本地值
  int tp_scrach_end_number_1 = 0; // 存储的本地值
  int tp_scrach_end_number_2 = 0; // 存储的本地值
  int tp_scrach_end_number_3 = 0; // 存储的本地值
  int tp_scrach_end_number_4 = 0; // 存储的本地值
  int tp_scrach_end_number_5 = 0; // 存储的本地值
  int tp_scrach_end_number_6 = 0; // 存储的本地值
  int tp_currentNumberIndex = 0;
  int tp_domand_number = 0;
  int tp_tx_card_first = 0;
  int tp_tx_dice_index = 0;
  int tp_quiz_task_index = 0;
  int new_ad_console = 1;
  int tp_zhuan_number = 0;
  int tp_quiz_tap_index = 0;

  // int tp_login_index = 0;
  // int tp_tx_probability_index = 0;
  int tp_scratch_not_award_number = 0;

  // 主题类型
  int tp_quiz_model_index = 0;

  // 当前第几题
  int tp_quiz_num_index = 0;
  int tp_quzi_row = 0;
  int tp_wheel_number = 2;
  int tp_pig_level = 0;
  double tp_pig_level_index = 0.0;
  int tp_quiz_all_num = 0;
  int quiz_console = 5;

  String get tp_currentNumberIndexName => 'tp_currentNumberIndex';

  String get tp_dice_numberName => 'tp_dice_number';

  String get tp_domand_numberName => 'tp_domand_number';

  String get tp_sound_musicName => 'tp_sound_music';

  String get tp_bg_musicName => 'tp_bg_music';

  String get tp_Level_numberName => 'tp_Level_number';

  String get tp_Level_inedxName => 'tp_Level_inedx';

  String get tp_fk_number_statusName => 'tp_fk_number_status';

  String get tp_fk_ip_statusName => 'tp_fk_ip_status';

  String get tp_fk_decvice_statusName => 'tp_fk_decvice_status';

  String get tp_ad_show_numberName => 'tp_ad_show_number';

  String get tp_ad_all_numberName => 'tp_ad_all_number';

  String get tp_ad_show_indexName => 'tp_ad_show_index';

  String get tp_ad_reawrd_all_numberName => 'tp_ad_reawrd_all_number';

  String get tp_ad_short_show_numberName => 'tp_ad_short_show_number';

  String get tp_fk_ad_short_showName => 'tp_fk_ad_short_show';

  String get tp_ad_short_close_numberName => 'tp_ad_short_close_number';

  String get tp_fk_ad_short_closeName => 'tp_fk_ad_short_close';

  String get tp_new_guideName => 'tp_new_guide';

  String get tp_ratio_strName => 'tp_ratio_str';

  String get tp_dolas_1000Name => 'tp_dolas_1000';

  String get tp_dolas_800Name => 'tp_dolas_800';

  String get tp_100_timer_starName => 'tp_100_timer_star';

  String get tp_dolas_numberName => 'tp_dolas_number';

  String get tp_card_numberName => 'tp_card_number';

  String get tp_show_dolas_aniName => 'tp_show_dolas_ani';

  String get tp_box_indexName => 'tp_box_index';

  String get tp_txing_statusName => 'tp_txing_status';

  String get tp_tx_ing_numberName => 'tp_tx_ing_number';

  String get tp_account_seled_indexName => 'tp_account_seled_index';

  String get tp_tx_ing_accountName => 'tp_tx_ing_account';

  String get tp_tx_bubble_indexName => 'tp_tx_bubble_index';

  String get tp_tx_card_indexName => 'tp_tx_card_index';

  String get tp_tx_wheel_indexName => 'tp_tx_wheel_index';

  String get tp_tx_quiz_indexName => 'tp_tx_quiz_index';

  String get tp_tx_task_indexName => 'tp_tx_task_index';

  String get tp_tx_card_firstName => 'tp_tx_card_first';

  String get tp_account_idName => 'tp_account_id';

  String get tp_tx_dice_indexName => 'tp_tx_dice_index';

  // String get tp_login_indexName => 'tp_login_index';
  // String get tp_tx_probability_indexName => 'tp_tx_probability_index';
  String get tp_tx_first_statusName => 'tp_tx_first_status';

  String get tp_tx_last_statusName => 'tp_tx_last_status';

  String get tp_current_rankingName => 'tp_current_ranking';

  String get tp_all_rankingName => 'tp_all_ranking';

  String get tp_old_guideName => 'tp_old_guide';

  String get tp_scratch_not_award_numberName => 'tp_scratch_not_award_number';

  String get tp_cloak_statusName => 'tp_cloak_status';

  String get tp_show_box_tipsName => 'tp_show_box_tips';

  String get tp_first_box_tipsName => 'tp_first_box_tips';

  String get tp_first_show_cashName => 'tp_first_show_cash';

  String get tp_scratch_guideName => 'tp_scratch_guide';

  String get tp_open_txName => 'tp_open_tx';

  String get tp_tx_task2_tipsName => 'tp_tx_task2_tips';

  String get tp_last_tx_endName => 'tp_last_tx_end';

  String get is_end_ScratchName => 'is_end_Scratch';

  String get tp_yunying_1Name => 'tp_yunying_1';

  String get tp_yunying_3Name => 'tp_yunying_3';

  String get tp_show_boxName => 'tp_show_box';

  String get tp_tx_task3_tipsName => 'tp_tx_task3_tips';

  String get tp_tx_task4_tipsName => 'tp_tx_task4_tips';

  String get tp_tx_end_statusName => 'tp_tx_end_status';

  String get tp_dolas_old_numberName => 'tp_dolas_old_number';

  String get tp_afSwitchName => 'tp_afSwitch';

  String get tp_set_rootName => 'tp_set_root';

  String get tp_login_statusName => 'tp_login_status';

  String get tp_af_statusName => 'tp_af_status';

  String get tp_newA_guideName => 'tp_newA_guide';

  String get tp_good_review_statusName => 'tp_good_review_status';

  String get tp_card_a_numberName => 'tp_card_a_number';

  String get tp_quiz_model_indexName => 'tp_quiz_model_index';

  String get tp_quiz_num_indexName => 'tp_quiz_num_index';

  String get tp_quzi_rowName => 'tp_quzi_row';

  String get tp_wheel_numberName => 'tp_wheel_number';

  String get tp_pig_levelName => 'tp_pig_level';

  String get tp_pig_level_indexName => 'tp_pig_level_index';

  String get tp_quiz_task_indexName => 'tp_quiz_task_index';

  String get new_ad_consoleName => 'new_ad_console';

  String get tp_zhuan_numberName => 'tp_zhuan_number';

  String get tp_quiz_all_numName => 'tp_quiz_all_num';

  String get tp_quiz_tap_indexName => 'tp_quiz_tap_index';

  String get tp_show_80_popName => 'tp_show_80_pop';

  String get tp_show_rankName => 'tp_show_rank';

  String get tp_tx_ing_statusName => 'tp_tx_ing_status';

  String get add_olduser_pointName => 'add_olduser_point';

  String get tp_install_statusName => 'tp_install_status';

  String get quiz_consoleName => 'quiz_console';

  // 3. 初始化：从本地存储加载数据（组件初始化时调用）
  Future<void> init() async {
    await (_triggerInitialization ??= _trigger.init());
    final prefs = await SharedPreferences.getInstance();
    // 从本地读取值（key自定义，需与存储时一致）
    // tp_tx_probability_index = prefs.getInt('tp_tx_probability_index') ?? 0;
    // tp_login_index = prefs.getInt('tp_login_index') ?? 0;
    tp_tx_dice_index = prefs.getInt('tp_tx_dice_index') ?? 0;
    tp_tx_card_first = prefs.getInt('tp_tx_card_first') ?? 0;
    tp_domand_number = prefs.getInt('tp_domand_number') ?? 0;
    tp_dice_number = prefs.getInt('tp_dice_number') ?? 0;
    tp_card_number = prefs.getInt('tp_card_number') ?? 0;
    tp_box_index = prefs.getInt('tp_box_index') ?? 0;
    tp_tx_quiz_index = prefs.getInt('tp_tx_quiz_index') ?? 0;
    tp_wheel_number = prefs.getInt('tp_wheel_number') ?? 0;
    tp_pig_level = prefs.getInt('tp_pig_level') ?? 0;
    tp_pig_level_index = prefs.getDouble('tp_pig_level_index') ?? 0.0;
    add_olduser_point = prefs.getDouble('add_olduser_point') ?? 0.03;
    tp_tx_card_index = prefs.getInt('tp_tx_card_index') ?? 0;
    tp_tx_wheel_index = prefs.getInt('tp_tx_wheel_index') ?? 0;
    tp_tx_bubble_index = prefs.getInt('tp_tx_bubble_index') ?? 0;
    tp_current_ranking = prefs.getInt('tp_current_ranking') ?? 99;
    tp_all_ranking = prefs.getInt('tp_all_ranking') ?? 388;
    tp_rank_ad_count = prefs.getInt('tp_rank_ad_count') ?? 388;
    tp_tx_task_index = prefs.getInt('tp_tx_task_index') ?? 0;
    tp_quiz_task_index = prefs.getInt('tp_quiz_task_index') ?? 0;
    tp_tx_ing_account = TPPaymentConfig.paymentIndex(
      prefs.getInt('tp_tx_ing_account') ?? 0,
    );
    tp_tx_ing_number = prefs.getInt('tp_tx_ing_number') ?? 0;
    tp_card_a_number = prefs.getInt('tp_card_a_number') ?? 0;
    tp_quiz_model_index = prefs.getInt('tp_quiz_model_index') ?? 0;
    tp_quiz_num_index = prefs.getInt('tp_quiz_num_index') ?? 0;
    tp_zhuan_number = prefs.getInt('tp_zhuan_number') ?? 0;
    tp_quiz_all_num = prefs.getInt('tp_quiz_all_num') ?? 0;
    tp_quiz_tap_index = prefs.getInt('tp_quiz_tap_index') ?? 0;
    tp_scratch_not_award_number =
        prefs.getInt('tp_scratch_not_award_number') ?? 0;
    tp_account_seled_index = TPPaymentConfig.paymentIndex(
      prefs.getInt('tp_account_seled_index') ?? 0,
    );
    tp_scrach_unlock_index_0 = prefs.getInt('tp_scrach_unlock_index_0') ?? 0;
    tp_scrach_unlock_index_1 = prefs.getInt('tp_scrach_unlock_index_1') ?? 0;
    tp_ad_short_show_number = prefs.getInt('tp_ad_short_show_number') ?? 0;
    tp_ad_short_close_number = prefs.getInt('tp_ad_short_close_number') ?? 0;
    tp_ad_show_number = prefs.getInt('tp_ad_show_number') ?? 0;
    tp_key_number = prefs.getInt('tp_key_number') ?? 0;
    tp_quzi_row = prefs.getInt('tp_quzi_row') ?? 0;
    tp_wheel_number = prefs.getInt('tp_wheel_number') ?? 3;
    quiz_console = prefs.getInt('quiz_console') ?? 5;
    new_ad_console = prefs.getInt('new_ad_console') ?? 1;
    tp_bg_music = prefs.getBool('tp_bg_music') ?? true;
    tp_sound_music = prefs.getBool('tp_sound_music') ?? true;
    tp_tx_task3_tips = prefs.getBool('tp_tx_task3_tips') ?? false;
    tp_tx_task4_tips = prefs.getBool('tp_tx_task4_tips') ?? false;
    tp_txing_status = prefs.getBool('tp_txing_status') ?? false;
    tp_login_status = prefs.getBool('tp_login_status') ?? false;
    tp_good_review_status = prefs.getBool('tp_good_review_status') ?? false;
    tp_open_tx = prefs.getBool('tp_open_tx') ?? false;
    tp_install_status = prefs.getBool('tp_install_status') ?? false;
    tp_show_box = prefs.getBool('tp_show_box') ?? false;
    tp_afSwitch = prefs.getBool('tp_afSwitch') ?? true;
    tp_set_root = prefs.getBool('tp_set_root') ?? false;
    tp_show_rank = prefs.getBool('tp_show_rank') ?? false;
    tp_af_status = prefs.getBool('tp_af_status') ?? false;
    is_end_Scratch = prefs.getBool('is_end_Scratch') ?? true;
    tp_cloak_status = prefs.getBool('tp_cloak_status') ?? false;
    tp_show_box_tips = prefs.getBool('tp_show_box_tips') ?? false;
    tp_first_box_tips = prefs.getBool('tp_first_box_tips') ?? false;
    tp_fk_number_status = prefs.getBool('tp_fk_number_status') ?? false;
    tp_fk_decvice_status = prefs.getBool('tp_fk_decvice_status') ?? false;
    tp_fk_ad_short_show = prefs.getBool('tp_fk_ad_short_show') ?? false;
    tp_fk_ad_short_close = prefs.getBool('tp_fk_ad_short_close') ?? false;
    tp_fk_ip_status = prefs.getBool('tp_fk_ip_status') ?? false;
    tp_newA_guide = prefs.getBool('tp_newA_guide') ?? false;
    tp_scratch_guide = prefs.getBool('tp_scratch_guide') ?? true;
    tp_old_guide = prefs.getBool('tp_old_guide') ?? true;
    tp_new_guide = prefs.getBool('tp_new_guide') ?? false;
    tp_show_bubble = prefs.getBool('tp_show_bubble') ?? false;
    tp_show_dolas_ani = prefs.getBool('tp_show_dolas_ani') ?? false;
    tp_show_box_guide = prefs.getBool('tp_show_box_guide') ?? false;
    tp_dolas_800 = prefs.getBool('tp_dolas_800') ?? false;
    tp_dolas_1000 = prefs.getBool('tp_dolas_1000') ?? false;
    tp_100_timer_star = prefs.getBool('tp_100_timer_star') ?? false;
    tp_tx_first_status = prefs.getBool('tp_tx_first_status') ?? false;
    tp_tx_last_status = prefs.getBool('tp_tx_last_status') ?? false;
    tp_first_show_cash = prefs.getBool('tp_first_show_cash') ?? false;
    tp_tx_task2_tips = prefs.getBool('tp_tx_task2_tips') ?? false;
    tp_last_tx_end = prefs.getBool('tp_last_tx_end') ?? false;
    tp_yunying_3 = prefs.getBool('tp_yunying_3') ?? false;
    tp_yunying_1 = prefs.getBool('tp_yunying_1') ?? false;
    tp_tx_end_status = prefs.getBool('tp_tx_end_status') ?? false;
    tp_show_80_pop = prefs.getBool('tp_show_80_pop') ?? false;
    tp_tx_ing_status = prefs.getBool('tp_tx_ing_status') ?? false;
    tp_ad_reawrd_all_number = prefs.getInt('tp_ad_reawrd_all_number') ?? 0;
    tp_ad_all_number = prefs.getInt('tp_ad_all_number') ?? 0;
    tp_dolas_number = prefs.getDouble('tp_dolas_number') ?? 0.00;
    tp_dolas_old_number = prefs.getDouble('tp_dolas_old_number') ?? 0.0;
    tp_ad_show_index = prefs.getInt('tp_ad_show_index') ?? 0;
    tp_Level_number = prefs.getInt('tp_Level_number') ?? 1;
    tp_Level_inedx = prefs.getInt('tp_Level_inedx') ?? 1;
    tp_scrach_end_number_0 = prefs.getInt('tp_scrach_end_number_0') ?? 0;
    tp_scrach_end_number_1 = prefs.getInt('tp_scrach_end_number_1') ?? 0;
    tp_scrach_end_number_2 = prefs.getInt('tp_scrach_end_number_2') ?? 0;
    tp_scrach_end_number_3 = prefs.getInt('tp_scrach_end_number_3') ?? 0;
    tp_scrach_end_number_4 = prefs.getInt('tp_scrach_end_number_4') ?? 0;
    tp_scrach_end_number_5 = prefs.getInt('tp_scrach_end_number_5') ?? 0;
    tp_scrach_end_number_6 = prefs.getInt('tp_scrach_end_number_6') ?? 0;
    tp_currentNumberIndex = prefs.getInt('tp_currentNumberIndex') ?? 0;
    tp_scratch_status_0 = prefs.getBool('tp_scratch_status_0') ?? true;
    tp_scratch_status_1 = prefs.getBool('tp_scratch_status_1') ?? true;
    tp_scratch_status_2 = prefs.getBool('tp_scratch_status_2') ?? true;
    tp_scratch_status_3 = prefs.getBool('tp_scratch_status_3') ?? true;
    tp_scratch_status_4 = prefs.getBool('tp_scratch_status_4') ?? true;
    tp_scratch_status_5 = prefs.getBool('tp_scratch_status_5') ?? true;
    tp_scratch_status_6 = prefs.getBool('tp_scratch_status_6') ?? true;
    tp_scratch_status_7 = prefs.getBool('tp_scratch_status_7') ?? true;
    tp_scratch_status_8 = prefs.getBool('tp_scratch_status_8') ?? true;
    tp_ratio_str = prefs.getString('tp_ratio_str') ?? '90';
    tp_account_id = prefs.getString('tp_account_id') ?? '';
    tp_tx_list = prefs.getString("tp_tx_list") ?? "";
    // init tx
    // if (tp_tx_list.isEmpty) {
    //   String jsonTXString = await rootBundle.loadString("tp_tx_list".jsons());
    //   Map<String, dynamic> json_tx = jsonDecode(jsonTXString);
    //   prefs.setString('tp_tx_list',jsonTXString);
    //   txEntity = SJTXModel.fromJson(json_tx);
    // } else {
    //   String jsonTXString = prefs.getString('tp_tx_list') ?? "";
    //   Map<String, dynamic> json_tx = jsonDecode(jsonTXString);
    //   txEntity = SJTXModel.fromJson(json_tx);
    // }
    notifyListeners(); // 加载完成后通知UI更新
  }

  // 通用bool
  Future<bool> updateBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final result = await prefs.setBool(key, value);
    await init();
    return result;
  }

  // 通用int
  Future<bool> updateint(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    final result = await prefs.setInt(key, value);
    await init();
    return result;
  }

  // 通用double
  Future<bool> updatedouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == TPLocalProvider.instance.tp_dolas_numberName &&
        tp_dolas_number <= 0) {
      await updateBool(tp_first_show_cashName, true);
    }
    if (key == TPLocalProvider.instance.tp_dolas_numberName && value > 0) {
      // TODO: 业务通知组件尚未接入。
      // TPPigDolasUpdateNotificationService.sendToQuizProgressNotification(0);
      await updatedouble(tp_dolas_old_numberName, tp_dolas_old_number + value);
    }
    if (key == TPLocalProvider.instance.tp_dolas_numberName) {
      value += tp_dolas_number;
    }
    final result = await prefs.setDouble(key, value);

    if (key == TPLocalProvider.instance.tp_pig_level_indexName) {
      // TODO: 业务通知组件尚未接入。
      // TPPigCashNotificationService.sendToQuizProgressNotification(0);
      // TODO: 业务通知组件尚未接入。
      // TPPigDolasUpdateNotificationService.sendToQuizProgressNotification(0);
    }
    // 开始提现
    ASLogger.instance.debug(
      'value=$value,tp_pig_level=$tp_pig_level, tp_show_rank=$tp_show_rank',
    );
    if (key == TPLocalProvider.instance.tp_pig_level_indexName &&
        value >= 10 &&
        tp_pig_level == 2 &&
        tp_show_rank == false) {
      await updateBool(tp_tx_ing_statusName, true);
      await updateint(tp_tx_task_indexName, 0);
      await updateint(tp_tx_quiz_indexName, 0);
      await updateint(tp_tx_quiz_indexName, 0);
      await updateint(tp_tx_bubble_indexName, 0);
      // TODO: 对应业务弹窗和页面尚未接入。
      // if (homeKey.currentState!.mounted) {
      //         // 到达100升级钻石猪
      //         homeKey.currentState!.context.tipShow(TPTXRankDialog());
      //       }
      await updateBool(tp_show_rankName, true);
      // TODO: 业务通知组件尚未接入。
      // TPPigCashNotificationService.sendToQuizProgressNotification(0);
    }
    Future.delayed(Duration(seconds: 1), () async {
      // 升级逻辑 + 1
      if (key == TPLocalProvider.instance.tp_dolas_numberName &&
          value >= TPNumberHelpers().intModel!.eqRange.first &&
          tp_pig_level == 0) {
        await updateint(tp_pig_levelName, tp_pig_level + 1);
        await updatedouble(tp_pig_level_indexName, 0);
        // TODO: 业务通知组件尚未接入。
        // TPPigCashNotificationService.sendToQuizProgressNotification(0);
        // TODO: 对应业务弹窗和页面尚未接入。
        // if (homeKey.currentState!.mounted) {
        //           // 到达100升级钻石猪
        //           homeKey.currentState!.context.tipShow(TPdolls100Dialog());
        //         }
      }
      // +2
      if (key == TPLocalProvider.instance.tp_pig_level_indexName &&
          value >= 20 &&
          tp_pig_level == 1) {
        await updateint(tp_pig_levelName, tp_pig_level + 1);
        await updatedouble(tp_pig_level_indexName, 0);
        // TODO: 业务通知组件尚未接入。
        // TPPigCashNotificationService.sendToQuizProgressNotification(0);
        // TODO: 对应业务弹窗和页面尚未接入。
        // if (homeKey.currentState!.mounted) {
        //           // 到达2升级金猪
        //           homeKey.currentState!.context.tipShow(TPGuide4Dialog());
        //         }
      }
    });

    if (key == TPLocalProvider.instance.tp_dolas_numberName && value > 0) {
      _trigger.check(
        TPLocalProvider.instance.tp_dolas_number.toInt(),
        onTrigger: (level) {
          ASLogger.instance.debug("触发 → 达到 $level");
          tp_event_fire('cash_money_detail', {'money_from': level});
        },
      );
      await updateBool(tp_show_dolas_aniName, true);
    }
    await init();
    if (result && key == tp_dolas_numberName) {
      // TODO: 业务通知组件尚未接入。
      // TPNoticeHelp().startSJForegroundService();
    }
    return result;
  }

  // 通用String
  Future<bool> updateString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final result = await prefs.setString(key, value);
    await init();
    return result;
  }

  // Future<void> updateTXInStatus(int status) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   txEntity.tx_info[tp_tx_ing_account].tx_list[tp_tx_ing_number].status = status;
  //   sharedPreferences.setString('tp_tx_list', jsonEncode(txEntity.toJson()));
  //   String jsonTXString = sharedPreferences.getString('tp_tx_list') ?? "";
  //   Map<String, dynamic> json_tx = jsonDecode(jsonTXString);
  //   txEntity = SJTXModel.fromJson(json_tx);
  // }
}
