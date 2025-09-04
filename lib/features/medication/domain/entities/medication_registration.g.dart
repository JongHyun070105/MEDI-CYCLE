// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicationRegistrationImpl _$$MedicationRegistrationImplFromJson(
        Map<String, dynamic> json) =>
    _$MedicationRegistrationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      manufacturer: json['manufacturer'] as String?,
      ingredient: json['ingredient'] as String?,
      dosage: json['dosage'] as String?,
      dailyFrequency: (json['dailyFrequency'] as num).toInt(),
      dosageTimes: (json['dosageTimes'] as List<dynamic>)
          .map((e) => DosageTime.fromJson(e as Map<String, dynamic>))
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isIndefinite: json['isIndefinite'] as bool? ?? false,
      status: $enumDecode(_$RegistrationStatusEnumMap, json['status']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MedicationRegistrationImplToJson(
        _$MedicationRegistrationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'manufacturer': instance.manufacturer,
      'ingredient': instance.ingredient,
      'dosage': instance.dosage,
      'dailyFrequency': instance.dailyFrequency,
      'dosageTimes': instance.dosageTimes,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isIndefinite': instance.isIndefinite,
      'status': _$RegistrationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$RegistrationStatusEnumMap = {
  RegistrationStatus.draft: 'draft',
  RegistrationStatus.completed: 'completed',
};

_$DosageTimeImpl _$$DosageTimeImplFromJson(Map<String, dynamic> json) =>
    _$DosageTimeImpl(
      id: json['id'] as String,
      time: TimeOfDay.fromJson(json['time'] as Map<String, dynamic>),
      mealRelation: $enumDecode(_$MealRelationEnumMap, json['mealRelation']),
      mealOffsetMinutes: (json['mealOffsetMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$$DosageTimeImplToJson(_$DosageTimeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'time': instance.time,
      'mealRelation': _$MealRelationEnumMap[instance.mealRelation]!,
      'mealOffsetMinutes': instance.mealOffsetMinutes,
    };

const _$MealRelationEnumMap = {
  MealRelation.before: 'before',
  MealRelation.after: 'after',
  MealRelation.anytime: 'anytime',
};

_$TimeOfDayImpl _$$TimeOfDayImplFromJson(Map<String, dynamic> json) =>
    _$TimeOfDayImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$$TimeOfDayImplToJson(_$TimeOfDayImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };
