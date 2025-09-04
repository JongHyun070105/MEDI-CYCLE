// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicationImpl _$$MedicationImplFromJson(Map<String, dynamic> json) =>
    _$MedicationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalQuantity: (json['totalQuantity'] as num).toInt(),
      remainingQuantity: (json['remainingQuantity'] as num).toInt(),
      instructions: json['instructions'] as String,
      imageUrl: json['imageUrl'] as String,
      status: $enumDecode(_$MedicationStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      notes: json['notes'] as String?,
      sideEffects: json['sideEffects'] as String?,
      interactions: json['interactions'] as String?,
      storageInstructions: json['storageInstructions'] as String?,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      prescriptionId: json['prescriptionId'] as String?,
      qrCode: json['qrCode'] as String?,
    );

Map<String, dynamic> _$$MedicationImplToJson(_$MedicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalQuantity': instance.totalQuantity,
      'remainingQuantity': instance.remainingQuantity,
      'instructions': instance.instructions,
      'imageUrl': instance.imageUrl,
      'status': _$MedicationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'notes': instance.notes,
      'sideEffects': instance.sideEffects,
      'interactions': instance.interactions,
      'storageInstructions': instance.storageInstructions,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'prescriptionId': instance.prescriptionId,
      'qrCode': instance.qrCode,
    };

const _$MedicationStatusEnumMap = {
  MedicationStatus.active: 'active',
  MedicationStatus.completed: 'completed',
  MedicationStatus.discontinued: 'discontinued',
  MedicationStatus.expired: 'expired',
  MedicationStatus.disposed: 'disposed',
};
