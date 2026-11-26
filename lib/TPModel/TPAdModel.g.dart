// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TPAdModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TPAdModel _$TPAdModelFromJson(Map<String, dynamic> json) => TPAdModel(
  iv:
      (json['iv'] as List<dynamic>?)
          ?.map((e) => TPAdUnitModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  rv:
      (json['rv'] as List<dynamic>?)
          ?.map((e) => TPAdUnitModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  alternateMode: json['nskdh_switch'] as bool?,
);

Map<String, dynamic> _$TPAdModelToJson(TPAdModel instance) => <String, dynamic>{
  'iv': instance.iv.map((e) => e.toJson()).toList(),
  'rv': instance.rv.map((e) => e.toJson()).toList(),
  'nskdh_switch': ?instance.alternateMode,
};

TPAdUnitModel _$TPAdUnitModelFromJson(Map<String, dynamic> json) =>
    TPAdUnitModel(
      unitId: json['unitId'] as String,
      platform: json['platform'] as String,
      adType: json['adtype'] as String,
      ctime: (json['ctime'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
    );

Map<String, dynamic> _$TPAdUnitModelToJson(TPAdUnitModel instance) =>
    <String, dynamic>{
      'unitId': instance.unitId,
      'platform': instance.platform,
      'adtype': instance.adType,
      'ctime': instance.ctime,
      'weight': instance.weight,
    };
