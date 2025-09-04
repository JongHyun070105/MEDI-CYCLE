// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicationScheduleImpl _$$MedicationScheduleImplFromJson(
        Map<String, dynamic> json) =>
    _$MedicationScheduleImpl(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      isTaken: json['isTaken'] as bool,
      isSkipped: json['isSkipped'] as bool,
      takenAt: json['takenAt'] == null
          ? null
          : DateTime.parse(json['takenAt'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MedicationScheduleImplToJson(
        _$MedicationScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationId': instance.medicationId,
      'medicationName': instance.medicationName,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'isTaken': instance.isTaken,
      'isSkipped': instance.isSkipped,
      'takenAt': instance.takenAt?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$DailyScheduleImpl _$$DailyScheduleImplFromJson(Map<String, dynamic> json) =>
    _$DailyScheduleImpl(
      date: DateTime.parse(json['date'] as String),
      schedules: (json['schedules'] as List<dynamic>)
          .map((e) => MedicationSchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalMedications: (json['totalMedications'] as num).toInt(),
      takenMedications: (json['takenMedications'] as num).toInt(),
      skippedMedications: (json['skippedMedications'] as num).toInt(),
    );

Map<String, dynamic> _$$DailyScheduleImplToJson(_$DailyScheduleImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'schedules': instance.schedules,
      'totalMedications': instance.totalMedications,
      'takenMedications': instance.takenMedications,
      'skippedMedications': instance.skippedMedications,
    };
