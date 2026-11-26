import 'package:json_annotation/json_annotation.dart';

part 'TPAdModel.g.dart';

/// 广告配置，按插屏广告和激励广告分组。
@JsonSerializable(explicitToJson: true)
class TPAdModel {
  const TPAdModel({required this.iv, required this.rv, this.alternateMode});

  @JsonKey(defaultValue: <TPAdUnitModel>[])
  final List<TPAdUnitModel> iv;

  @JsonKey(defaultValue: <TPAdUnitModel>[])
  final List<TPAdUnitModel> rv;

  /// 兼容广告管理器使用的可选模式开关。
  @JsonKey(name: 'nskdh_switch', includeIfNull: false)
  final bool? alternateMode;

  factory TPAdModel.fromJson(Map<String, dynamic> json) =>
      _$TPAdModelFromJson(json);

  Map<String, dynamic> toJson() => _$TPAdModelToJson(this);
}

/// 单个广告位的配置。
@JsonSerializable()
class TPAdUnitModel {
  const TPAdUnitModel({
    required this.unitId,
    required this.platform,
    required this.adType,
    required this.ctime,
    required this.weight,
  });

  final String unitId;
  final String platform;

  @JsonKey(name: 'adtype')
  final String adType;

  final int ctime;
  final int weight;

  factory TPAdUnitModel.fromJson(Map<String, dynamic> json) =>
      _$TPAdUnitModelFromJson(json);

  Map<String, dynamic> toJson() => _$TPAdUnitModelToJson(this);
}
