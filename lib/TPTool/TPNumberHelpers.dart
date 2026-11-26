import 'TPLogger.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:treeperks/TPTool/TPLocalProvider.dart';
import 'package:treeperks/TPTool/TPExtensionHelp.dart';
import '../TPModel/TPNumberModel.dart';

class TPNumberHelpers {
  static final TPNumberHelpers _instance = TPNumberHelpers._internal();

  factory TPNumberHelpers() {
    return _instance;
  }

  TPNumberHelpers._internal();

  TPAppConfig? intModel;

  Future<void> initNumberModel() async {
    await _psloadintDataFromLocate();
    await _psloadtaskDataFromLocate();
    await _psloadprobabilityDataFromLocate();
    await _psloadwinup_numberDataFromLocate();
    await _psloadlsattaskDataFromLocate();
  }

  Future<void> _psloadintDataFromLocate() async {
    String jsonString = await rootBundle.loadString("gp152_pig_number".jsons());
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    intModel = TPAppConfig.fromJson(jsonMap);
    ASLogger.instance.debug("PigWallets int jsonMap = $jsonMap");
    ASLogger.instance.debug("PigWallets int model = ${intModel?.eqRange}");
  }

  Future<void> _psloadtaskDataFromLocate() async {
    // String jsonString = await rootBundle.loadString("c130_withdraw_task".jsons());
    // Map<String, dynamic> jsonMap = json.decode(jsonString);
    // taskModel = TaskRootModel.fromJson(jsonMap);
    // ASLogger.instance.debug("PigWallets task json = ${taskModel}");
  }

  Future<void> _psloadlsattaskDataFromLocate() async {
    // String jsonString = await rootBundle.loadString("c130_withdraw_last_task".jsons());
    // Map<String, dynamic> jsonMap = json.decode(jsonString);
    // last_taskModel = TaskRootModel.fromJson(jsonMap);
    // ASLogger.instance.debug("PigWallets task json = ${last_taskModel}");
  }

  Future<void> _psloadprobabilityDataFromLocate() async {
    // String jsonString = await rootBundle.loadString("probability_reset".jsons());
    // Map<String, dynamic> jsonMap = json.decode(jsonString);
    // probabilityConfigModel = ProbabilityConfig.fromJson(jsonMap);
    // ASLogger.instance.debug("PigWallets probabilityConfig json = ${probabilityConfigModel}");
  }

  Future<void> _psloadwinup_numberDataFromLocate() async {
    // String jsonString = await rootBundle.loadString("winup_number".jsons());
    // Map<String, dynamic> jsonMap = json.decode(jsonString);
    // bonusConfigModel = BonusConfig.fromJson(jsonMap);
    // ASLogger.instance.debug("PigWallets winup_number json = ${bonusConfigModel}");
  }

  // 插屏概率获取
  bool checkProbability() {
    // 找到 value 所在的区间
    int range = 0;
    for (var item in intModel!.intadPoint) {
      if (TPLocalProvider.instance.tp_dolas_old_number >=
              item.firstNumber * dolasbeishu() &&
          TPLocalProvider.instance.tp_dolas_old_number <=
              item.endNumber * dolasbeishu()) {
        range = item.point;
        break;
      }
    }

    if (range <= 0.0) {
      return false;
    }

    double point = range.toDouble();
    ASLogger.instance.debug('range=$range');
    // 随机概率判断
    double rand = Random().nextDouble() * 100; // 0.0 ~ 1.0
    ASLogger.instance.debug('rand=$rand');
    return rand <= point;
  }

  /// 获取气泡奖励值
  double getPrizeWithDolasNum() {
    for (var item in intModel!.moneyPrize) {
      int start = item.firstNumber * dolasbeishu();
      int end = item.endNumber * dolasbeishu();

      if (TPLocalProvider.instance.tp_dolas_number >= start &&
          TPLocalProvider.instance.tp_dolas_number < end) {
        double min = item.prize.first * dolasbeishu();
        double max = item.prize.last * dolasbeishu();
        ASLogger.instance.debug(
          'XXXXXXX${0.to2Double(_randomBetween(min, max))}',
        );
        return 0.to2Double(_randomBetween(min, max));
      }
    }

    /// 如果超出所有区间，返回最后一段
    var last = intModel!.moneyPrize.last;
    ASLogger.instance.debug(
      'YYYYYYY${0.to2Double(_randomBetween(last.prize.first * dolasbeishu(), last.prize.last * dolasbeishu()))}',
    );
    return 0.to2Double(
      _randomBetween(
        last.prize.first * dolasbeishu(),
        last.prize.last * dolasbeishu(),
      ),
    );
  }

  /// 获取金额范围奖励值
  List<double> getPrizeWithDolasNSize(double tp_dolas) {
    for (var item in intModel!.moneyPrize) {
      int start = item.firstNumber;
      int end = item.endNumber;

      if (tp_dolas >= start && tp_dolas < end) {
        return item.prize;
      }
    }

    /// 如果超出所有区间，返回最后一段
    var last = intModel!.moneyPrize.last;
    return last.prize;
  }

  /// 获取钻石或者金砖奖励值
  double getPrizeWithDomandGoldNum() {
    List<TPMoneyPrize> model = TPLocalProvider.instance.tp_pig_level == 1
        ? intModel!.diamondPrize
        : intModel!.goldPrize;
    for (var item in model) {
      int start = item.firstNumber;
      int end = item.endNumber;

      if (TPLocalProvider.instance.tp_pig_level_index >= start &&
          TPLocalProvider.instance.tp_pig_level_index < end) {
        double min = item.prize.first;
        double max = item.prize.last;
        return 0.to2Double(_randomBetween(min, max));
      }
    }

    /// 如果超出所有区间，返回最后一段
    var last = model.last;
    return 0.to2Double(_randomBetween(last.prize.first, last.prize.last));
  }

  /// 生成[min, max]之间随机整数（兼容 double）
  double _randomBetween(double min, double max) {
    if (min > max) {
      throw ArgumentError('min should be less than or equal to max');
    }

    final r = Random();
    // Generate a double between 0.0 and 1.0, then scale to range
    double value = min + r.nextDouble() * (max - min);
    // Round to 2 decimal places
    return double.parse(value.toStringAsFixed(2));
  }

  int dolasbeishu() => 1;
}
