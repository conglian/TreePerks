// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TPNumberModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TPAppConfig _$TPAppConfigFromJson(Map<String, dynamic> json) => TPAppConfig(
  eqRange:
      (json['eq_range'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  newAdConsole: (json['new_ad_console'] as num?)?.toInt() ?? 0,
  queueNumber:
      (json['queue_number'] as List<dynamic>?)
          ?.map((e) => TPQueueNumber.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  tixianTask:
      (json['tixian_task'] as List<dynamic>?)
          ?.map((e) => TPTixianTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  intadPoint:
      (json['intad_point'] as List<dynamic>?)
          ?.map((e) => TPIntAdPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  wheelRange:
      (json['wheel_range'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  firstAdPrize: (json['first_ad_prize'] as num?)?.toDouble() ?? 0,
  growPoint:
      (json['grow_point'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  moneyPrize:
      (json['money_prize'] as List<dynamic>?)
          ?.map((e) => TPMoneyPrize.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  diamondPrize:
      (json['diamond_prize'] as List<dynamic>?)
          ?.map((e) => TPMoneyPrize.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  goldPrize:
      (json['gold_prize'] as List<dynamic>?)
          ?.map((e) => TPMoneyPrize.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$TPAppConfigToJson(TPAppConfig instance) =>
    <String, dynamic>{
      'eq_range': instance.eqRange,
      'new_ad_console': instance.newAdConsole,
      'queue_number': instance.queueNumber.map((e) => e.toJson()).toList(),
      'tixian_task': instance.tixianTask.map((e) => e.toJson()).toList(),
      'intad_point': instance.intadPoint.map((e) => e.toJson()).toList(),
      'wheel_range': instance.wheelRange,
      'first_ad_prize': instance.firstAdPrize,
      'grow_point': instance.growPoint,
      'money_prize': instance.moneyPrize.map((e) => e.toJson()).toList(),
      'diamond_prize': instance.diamondPrize.map((e) => e.toJson()).toList(),
      'gold_prize': instance.goldPrize.map((e) => e.toJson()).toList(),
    };

TPQueueNumber _$TPQueueNumberFromJson(Map<String, dynamic> json) =>
    TPQueueNumber(
      intAll: (json['int_all'] as num?)?.toInt() ?? 0,
      intAllDelete:
          (json['int_all_delete'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      intCurrent: (json['int_current'] as num?)?.toInt() ?? 0,
      intCurrentDelete:
          (json['int_current_delete'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
    );

Map<String, dynamic> _$TPQueueNumberToJson(TPQueueNumber instance) =>
    <String, dynamic>{
      'int_all': instance.intAll,
      'int_all_delete': instance.intAllDelete,
      'int_current': instance.intCurrent,
      'int_current_delete': instance.intCurrentDelete,
    };

TPTixianTask _$TPTixianTaskFromJson(Map<String, dynamic> json) => TPTixianTask(
  title: json['title'] as String? ?? '',
  data: (json['data'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TPTixianTaskToJson(TPTixianTask instance) =>
    <String, dynamic>{'title': instance.title, 'data': instance.data};

TPIntAdPoint _$TPIntAdPointFromJson(Map<String, dynamic> json) => TPIntAdPoint(
  firstNumber: (json['first_number'] as num?)?.toInt() ?? 0,
  point: (json['point'] as num?)?.toInt() ?? 0,
  endNumber: (json['end_number'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TPIntAdPointToJson(TPIntAdPoint instance) =>
    <String, dynamic>{
      'first_number': instance.firstNumber,
      'point': instance.point,
      'end_number': instance.endNumber,
    };

TPMoneyPrize _$TPMoneyPrizeFromJson(Map<String, dynamic> json) => TPMoneyPrize(
  firstNumber: (json['first_number'] as num?)?.toInt() ?? 0,
  type: (json['type'] as num?)?.toInt() ?? 0,
  prize:
      (json['prize'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
      [],
  endNumber: (json['end_number'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TPMoneyPrizeToJson(TPMoneyPrize instance) =>
    <String, dynamic>{
      'first_number': instance.firstNumber,
      'type': instance.type,
      'prize': instance.prize,
      'end_number': instance.endNumber,
    };
