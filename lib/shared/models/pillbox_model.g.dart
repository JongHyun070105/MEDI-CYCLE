// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pillbox_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PillboxStatusImpl _$$PillboxStatusImplFromJson(Map<String, dynamic> json) =>
    _$PillboxStatusImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      detected: json['detected'] as bool,
      batteryPercent: (json['batteryPercent'] as num?)?.toInt(),
      isLocked: json['isLocked'] as bool,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PillboxStatusImplToJson(_$PillboxStatusImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'detected': instance.detected,
      'batteryPercent': instance.batteryPercent,
      'isLocked': instance.isLocked,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$PillboxStatusUpdateImpl _$$PillboxStatusUpdateImplFromJson(
        Map<String, dynamic> json) =>
    _$PillboxStatusUpdateImpl(
      detected: json['detected'] as bool?,
      batteryPercent: (json['batteryPercent'] as num?)?.toInt(),
      isLocked: json['isLocked'] as bool?,
    );

Map<String, dynamic> _$$PillboxStatusUpdateImplToJson(
        _$PillboxStatusUpdateImpl instance) =>
    <String, dynamic>{
      'detected': instance.detected,
      'batteryPercent': instance.batteryPercent,
      'isLocked': instance.isLocked,
    };
