import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication.freezed.dart';
part 'medication.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication({
    required String id,
    required String name,
    required String dosage,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required int totalQuantity,
    required int remainingQuantity,
    required String instructions,
    required String imageUrl,
    required MedicationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? notes,
    String? sideEffects,
    String? interactions,
    String? storageInstructions,
    DateTime? expiryDate,
    String? prescriptionId,
    String? qrCode,
  }) = _Medication;

  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);
}

enum MedicationStatus {
  active,
  completed,
  discontinued,
  expired,
  disposed
}

extension MedicationStatusExtension on MedicationStatus {
  String get displayName {
    switch (this) {
      case MedicationStatus.active:
        return '복용 중';
      case MedicationStatus.completed:
        return '복용 완료';
      case MedicationStatus.discontinued:
        return '복용 중단';
      case MedicationStatus.expired:
        return '유효기간 만료';
      case MedicationStatus.disposed:
        return '폐기됨';
    }
  }

  bool get isActive => this == MedicationStatus.active;
  bool get isCompleted => this == MedicationStatus.completed;
  bool get isExpired => this == MedicationStatus.expired;
  bool get isDisposed => this == MedicationStatus.disposed;
}
