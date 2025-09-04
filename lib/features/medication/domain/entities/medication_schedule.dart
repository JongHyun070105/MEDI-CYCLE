import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_schedule.freezed.dart';
part 'medication_schedule.g.dart';

@freezed
class MedicationSchedule with _$MedicationSchedule {
  const factory MedicationSchedule({
    required String id,
    required String medicationId,
    required String medicationName,
    required DateTime scheduledTime,
    required bool isTaken,
    required bool isSkipped,
    DateTime? takenAt,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MedicationSchedule;

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) =>
      _$MedicationScheduleFromJson(json);
}

@freezed
class DailySchedule with _$DailySchedule {
  const factory DailySchedule({
    required DateTime date,
    required List<MedicationSchedule> schedules,
    required int totalMedications,
    required int takenMedications,
    required int skippedMedications,
  }) = _DailySchedule;

  factory DailySchedule.fromJson(Map<String, dynamic> json) =>
      _$DailyScheduleFromJson(json);
}

extension DailyScheduleExtension on DailySchedule {
  double get completionRate {
    if (totalMedications == 0) return 0.0;
    return takenMedications / totalMedications;
  }

  bool get isCompleted => takenMedications == totalMedications;
  bool get hasSkipped => skippedMedications > 0;
}
