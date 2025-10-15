// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicationImpl _$$MedicationImplFromJson(Map<String, dynamic> json) =>
    _$MedicationImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      dailyCount: (json['dailyCount'] as num).toInt(),
      time1: json['time1'] == null
          ? null
          : Time.fromJson(json['time1'] as Map<String, dynamic>),
      time1Meal: json['time1Meal'] as String?,
      time1OffsetMin: (json['time1OffsetMin'] as num?)?.toInt(),
      time2: json['time2'] == null
          ? null
          : Time.fromJson(json['time2'] as Map<String, dynamic>),
      time2Meal: json['time2Meal'] as String?,
      time2OffsetMin: (json['time2OffsetMin'] as num?)?.toInt(),
      time3: json['time3'] == null
          ? null
          : Time.fromJson(json['time3'] as Map<String, dynamic>),
      time3Meal: json['time3Meal'] as String?,
      time3OffsetMin: (json['time3OffsetMin'] as num?)?.toInt(),
      time4: json['time4'] == null
          ? null
          : Time.fromJson(json['time4'] as Map<String, dynamic>),
      time4Meal: json['time4Meal'] as String?,
      time4OffsetMin: (json['time4OffsetMin'] as num?)?.toInt(),
      time5: json['time5'] == null
          ? null
          : Time.fromJson(json['time5'] as Map<String, dynamic>),
      time5Meal: json['time5Meal'] as String?,
      time5OffsetMin: (json['time5OffsetMin'] as num?)?.toInt(),
      time6: json['time6'] == null
          ? null
          : Time.fromJson(json['time6'] as Map<String, dynamic>),
      time6Meal: json['time6Meal'] as String?,
      time6OffsetMin: (json['time6OffsetMin'] as num?)?.toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isIndefinite: json['isIndefinite'] as bool,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MedicationImplToJson(_$MedicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'dailyCount': instance.dailyCount,
      'time1': instance.time1,
      'time1Meal': instance.time1Meal,
      'time1OffsetMin': instance.time1OffsetMin,
      'time2': instance.time2,
      'time2Meal': instance.time2Meal,
      'time2OffsetMin': instance.time2OffsetMin,
      'time3': instance.time3,
      'time3Meal': instance.time3Meal,
      'time3OffsetMin': instance.time3OffsetMin,
      'time4': instance.time4,
      'time4Meal': instance.time4Meal,
      'time4OffsetMin': instance.time4OffsetMin,
      'time5': instance.time5,
      'time5Meal': instance.time5Meal,
      'time5OffsetMin': instance.time5OffsetMin,
      'time6': instance.time6,
      'time6Meal': instance.time6Meal,
      'time6OffsetMin': instance.time6OffsetMin,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isIndefinite': instance.isIndefinite,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$TimeImpl _$$TimeImplFromJson(Map<String, dynamic> json) => _$TimeImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$$TimeImplToJson(_$TimeImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };

_$MedicationCreateRequestImpl _$$MedicationCreateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$MedicationCreateRequestImpl(
      name: json['name'] as String,
      dailyCount: (json['dailyCount'] as num).toInt(),
      time1: json['time1'] == null
          ? null
          : Time.fromJson(json['time1'] as Map<String, dynamic>),
      time1Meal: json['time1Meal'] as String?,
      time1OffsetMin: (json['time1OffsetMin'] as num?)?.toInt(),
      time2: json['time2'] == null
          ? null
          : Time.fromJson(json['time2'] as Map<String, dynamic>),
      time2Meal: json['time2Meal'] as String?,
      time2OffsetMin: (json['time2OffsetMin'] as num?)?.toInt(),
      time3: json['time3'] == null
          ? null
          : Time.fromJson(json['time3'] as Map<String, dynamic>),
      time3Meal: json['time3Meal'] as String?,
      time3OffsetMin: (json['time3OffsetMin'] as num?)?.toInt(),
      time4: json['time4'] == null
          ? null
          : Time.fromJson(json['time4'] as Map<String, dynamic>),
      time4Meal: json['time4Meal'] as String?,
      time4OffsetMin: (json['time4OffsetMin'] as num?)?.toInt(),
      time5: json['time5'] == null
          ? null
          : Time.fromJson(json['time5'] as Map<String, dynamic>),
      time5Meal: json['time5Meal'] as String?,
      time5OffsetMin: (json['time5OffsetMin'] as num?)?.toInt(),
      time6: json['time6'] == null
          ? null
          : Time.fromJson(json['time6'] as Map<String, dynamic>),
      time6Meal: json['time6Meal'] as String?,
      time6OffsetMin: (json['time6OffsetMin'] as num?)?.toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isIndefinite: json['isIndefinite'] as bool? ?? false,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MedicationCreateRequestImplToJson(
        _$MedicationCreateRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dailyCount': instance.dailyCount,
      'time1': instance.time1,
      'time1Meal': instance.time1Meal,
      'time1OffsetMin': instance.time1OffsetMin,
      'time2': instance.time2,
      'time2Meal': instance.time2Meal,
      'time2OffsetMin': instance.time2OffsetMin,
      'time3': instance.time3,
      'time3Meal': instance.time3Meal,
      'time3OffsetMin': instance.time3OffsetMin,
      'time4': instance.time4,
      'time4Meal': instance.time4Meal,
      'time4OffsetMin': instance.time4OffsetMin,
      'time5': instance.time5,
      'time5Meal': instance.time5Meal,
      'time5OffsetMin': instance.time5OffsetMin,
      'time6': instance.time6,
      'time6Meal': instance.time6Meal,
      'time6OffsetMin': instance.time6OffsetMin,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isIndefinite': instance.isIndefinite,
      'notes': instance.notes,
    };

_$MedicationUpdateRequestImpl _$$MedicationUpdateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$MedicationUpdateRequestImpl(
      name: json['name'] as String?,
      dailyCount: (json['dailyCount'] as num?)?.toInt(),
      time1: json['time1'] == null
          ? null
          : Time.fromJson(json['time1'] as Map<String, dynamic>),
      time1Meal: json['time1Meal'] as String?,
      time1OffsetMin: (json['time1OffsetMin'] as num?)?.toInt(),
      time2: json['time2'] == null
          ? null
          : Time.fromJson(json['time2'] as Map<String, dynamic>),
      time2Meal: json['time2Meal'] as String?,
      time2OffsetMin: (json['time2OffsetMin'] as num?)?.toInt(),
      time3: json['time3'] == null
          ? null
          : Time.fromJson(json['time3'] as Map<String, dynamic>),
      time3Meal: json['time3Meal'] as String?,
      time3OffsetMin: (json['time3OffsetMin'] as num?)?.toInt(),
      time4: json['time4'] == null
          ? null
          : Time.fromJson(json['time4'] as Map<String, dynamic>),
      time4Meal: json['time4Meal'] as String?,
      time4OffsetMin: (json['time4OffsetMin'] as num?)?.toInt(),
      time5: json['time5'] == null
          ? null
          : Time.fromJson(json['time5'] as Map<String, dynamic>),
      time5Meal: json['time5Meal'] as String?,
      time5OffsetMin: (json['time5OffsetMin'] as num?)?.toInt(),
      time6: json['time6'] == null
          ? null
          : Time.fromJson(json['time6'] as Map<String, dynamic>),
      time6Meal: json['time6Meal'] as String?,
      time6OffsetMin: (json['time6OffsetMin'] as num?)?.toInt(),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isIndefinite: json['isIndefinite'] as bool?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MedicationUpdateRequestImplToJson(
        _$MedicationUpdateRequestImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dailyCount': instance.dailyCount,
      'time1': instance.time1,
      'time1Meal': instance.time1Meal,
      'time1OffsetMin': instance.time1OffsetMin,
      'time2': instance.time2,
      'time2Meal': instance.time2Meal,
      'time2OffsetMin': instance.time2OffsetMin,
      'time3': instance.time3,
      'time3Meal': instance.time3Meal,
      'time3OffsetMin': instance.time3OffsetMin,
      'time4': instance.time4,
      'time4Meal': instance.time4Meal,
      'time4OffsetMin': instance.time4OffsetMin,
      'time5': instance.time5,
      'time5Meal': instance.time5Meal,
      'time5OffsetMin': instance.time5OffsetMin,
      'time6': instance.time6,
      'time6Meal': instance.time6Meal,
      'time6OffsetMin': instance.time6OffsetMin,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isIndefinite': instance.isIndefinite,
      'notes': instance.notes,
    };
