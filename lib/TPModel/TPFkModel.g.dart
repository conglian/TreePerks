// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TPFkModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TPFkModel _$TPFkModelFromJson(Map<String, dynamic> json) => TPFkModel()
  ..ui = TPUIModel.fromJson(json['ui'] as Map<String, dynamic>)
  ..behavior = TPBehaviorModel.fromJson(
    json['behavior'] as Map<String, dynamic>,
  )
  ..device = (json['device'] as List<dynamic>).map((e) => e as String).toList();

Map<String, dynamic> _$TPFkModelToJson(TPFkModel instance) => <String, dynamic>{
  'ui': instance.ui,
  'behavior': instance.behavior,
  'device': instance.device,
};

TPUIModel _$TPUIModelFromJson(Map<String, dynamic> json) => TPUIModel()
  ..number = (json['number'] as num).toInt()
  ..behavior = (json['behavior'] as num).toInt()
  ..device = (json['device'] as num).toInt();

Map<String, dynamic> _$TPUIModelToJson(TPUIModel instance) => <String, dynamic>{
  'number': instance.number,
  'behavior': instance.behavior,
  'device': instance.device,
};

TPBehaviorModel _$TPBehaviorModelFromJson(Map<String, dynamic> json) =>
    TPBehaviorModel()
      ..ad_short_show = TPAdShortModel.fromJson(
        json['ad_short_show'] as Map<String, dynamic>,
      )
      ..ad_short_close = TPAdShortModel.fromJson(
        json['ad_short_close'] as Map<String, dynamic>,
      )
      ..wrong_deem_ad_less = (json['wrong_deem_ad_less'] as num).toInt()
      ..wrong_deem_ad_more = (json['wrong_deem_ad_more'] as num).toInt()
      ..no_install = (json['no_install'] as num).toInt()
      ..ad_daily_show = (json['ad_daily_show'] as num).toInt();

Map<String, dynamic> _$TPBehaviorModelToJson(TPBehaviorModel instance) =>
    <String, dynamic>{
      'ad_short_show': instance.ad_short_show,
      'ad_short_close': instance.ad_short_close,
      'wrong_deem_ad_less': instance.wrong_deem_ad_less,
      'wrong_deem_ad_more': instance.wrong_deem_ad_more,
      'no_install': instance.no_install,
      'ad_daily_show': instance.ad_daily_show,
    };

TPAdShortModel _$TPAdShortModelFromJson(Map<String, dynamic> json) =>
    TPAdShortModel()
      ..duration = (json['duration'] as num).toInt()
      ..value = (json['value'] as num).toInt();

Map<String, dynamic> _$TPAdShortModelToJson(TPAdShortModel instance) =>
    <String, dynamic>{'duration': instance.duration, 'value': instance.value};
