import 'package:json_annotation/json_annotation.dart';

part 'TPNumberModel.g.dart';

@JsonSerializable(explicitToJson: true)
class TPAppConfig {
  @JsonKey(name: 'eq_range', defaultValue: [])
  final List<int> eqRange;

  @JsonKey(name: 'new_ad_console', defaultValue: 0)
  final int newAdConsole;

  @JsonKey(name: 'queue_number', defaultValue: [])
  final List<TPQueueNumber> queueNumber;

  @JsonKey(name: 'tixian_task', defaultValue: [])
  final List<TPTixianTask> tixianTask;

  @JsonKey(name: 'intad_point', defaultValue: [])
  final List<TPIntAdPoint> intadPoint;

  @JsonKey(name: 'wheel_range', defaultValue: [])
  final List<int> wheelRange;

  @JsonKey(name: 'first_ad_prize', defaultValue: 0)
  final double firstAdPrize;

  @JsonKey(name: 'grow_point', defaultValue: [])
  final List<int> growPoint;

  @JsonKey(name: 'money_prize', defaultValue: [])
  final List<TPMoneyPrize> moneyPrize;

  @JsonKey(name: 'diamond_prize', defaultValue: [])
  final List<TPMoneyPrize> diamondPrize;

  @JsonKey(name: 'gold_prize', defaultValue: [])
  final List<TPMoneyPrize> goldPrize;

  TPAppConfig({
    required this.eqRange,
    required this.newAdConsole,
    required this.queueNumber,
    required this.tixianTask,
    required this.intadPoint,
    required this.wheelRange,
    required this.firstAdPrize,
    required this.growPoint,
    required this.moneyPrize,
    required this.diamondPrize,
    required this.goldPrize,
  });

  factory TPAppConfig.fromJson(Map<String, dynamic> json) =>
      _$TPAppConfigFromJson(json);
  Map<String, dynamic> toJson() => _$TPAppConfigToJson(this);
}

@JsonSerializable()
class TPQueueNumber {
  @JsonKey(name: 'int_all', defaultValue: 0)
  final int intAll;

  @JsonKey(name: 'int_all_delete', defaultValue: [])
  final List<int> intAllDelete;

  @JsonKey(name: 'int_current', defaultValue: 0)
  final int intCurrent;

  @JsonKey(name: 'int_current_delete', defaultValue: [])
  final List<int> intCurrentDelete;

  TPQueueNumber({
    required this.intAll,
    required this.intAllDelete,
    required this.intCurrent,
    required this.intCurrentDelete,
  });

  factory TPQueueNumber.fromJson(Map<String, dynamic> json) =>
      _$TPQueueNumberFromJson(json);
  Map<String, dynamic> toJson() => _$TPQueueNumberToJson(this);
}

@JsonSerializable()
class TPTixianTask {
  @JsonKey(name: 'title', defaultValue: '')
  final String title;

  @JsonKey(name: 'data', defaultValue: 0)
  final int data;

  TPTixianTask({required this.title, required this.data});

  factory TPTixianTask.fromJson(Map<String, dynamic> json) =>
      _$TPTixianTaskFromJson(json);
  Map<String, dynamic> toJson() => _$TPTixianTaskToJson(this);
}

@JsonSerializable()
class TPIntAdPoint {
  @JsonKey(name: 'first_number', defaultValue: 0)
  final int firstNumber;

  @JsonKey(name: 'point', defaultValue: 0)
  final int point;

  @JsonKey(name: 'end_number', defaultValue: 0)
  final int endNumber;

  TPIntAdPoint({
    required this.firstNumber,
    required this.point,
    required this.endNumber,
  });

  factory TPIntAdPoint.fromJson(Map<String, dynamic> json) =>
      _$TPIntAdPointFromJson(json);
  Map<String, dynamic> toJson() => _$TPIntAdPointToJson(this);
}

@JsonSerializable()
class TPMoneyPrize {
  @JsonKey(name: 'first_number', defaultValue: 0)
  final int firstNumber;

  @JsonKey(name: 'type', defaultValue: 0)
  final int type;

  @JsonKey(name: 'prize', defaultValue: [])
  final List<double> prize;

  @JsonKey(name: 'end_number', defaultValue: 0)
  final int endNumber;

  TPMoneyPrize({
    required this.firstNumber,
    required this.type,
    required this.prize,
    required this.endNumber,
  });

  factory TPMoneyPrize.fromJson(Map<String, dynamic> json) =>
      _$TPMoneyPrizeFromJson(json);
  Map<String, dynamic> toJson() => _$TPMoneyPrizeToJson(this);
}
