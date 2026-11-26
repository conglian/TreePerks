import 'package:json_annotation/json_annotation.dart';

part 'TPFkModel.g.dart';

@JsonSerializable()
class TPFkModel {
  late TPUIModel ui = TPUIModel();
  late TPBehaviorModel behavior = TPBehaviorModel();
  late List<String> device = [];
  TPFkModel();

  // 工厂构造函数，用于反序列化
  factory TPFkModel.fromJson(Map<String, dynamic> json) =>
      _$TPFkModelFromJson(json);

  // 序列化方法
  Map<String, dynamic> toJson() => _$TPFkModelToJson(this);
}

@JsonSerializable()
class TPUIModel {
  late int number = 0;
  late int behavior = 0;
  late int device = 0;
  TPUIModel();

  // 工厂构造函数，用于反序列化
  factory TPUIModel.fromJson(Map<String, dynamic> json) =>
      _$TPUIModelFromJson(json);

  // 序列化方法
  Map<String, dynamic> toJson() => _$TPUIModelToJson(this);
}

@JsonSerializable()
class TPBehaviorModel {
  late TPAdShortModel ad_short_show = TPAdShortModel();
  late TPAdShortModel ad_short_close = TPAdShortModel();
  late int wrong_deem_ad_less = 0;
  late int wrong_deem_ad_more = 0;
  late int no_install = 0;
  late int ad_daily_show = 0;
  TPBehaviorModel();

  // 工厂构造函数，用于反序列化
  factory TPBehaviorModel.fromJson(Map<String, dynamic> json) =>
      _$TPBehaviorModelFromJson(json);

  // 序列化方法
  Map<String, dynamic> toJson() => _$TPBehaviorModelToJson(this);
}

@JsonSerializable()
class TPAdShortModel {
  late int duration = 0;
  late int value = 0;

  TPAdShortModel();

  // 工厂构造函数，用于反序列化
  factory TPAdShortModel.fromJson(Map<String, dynamic> json) =>
      _$TPAdShortModelFromJson(json);

  // 序列化方法
  Map<String, dynamic> toJson() => _$TPAdShortModelToJson(this);
}
