import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_registration.freezed.dart';
part 'medication_registration.g.dart';

@freezed
class MedicationRegistration with _$MedicationRegistration {
  const factory MedicationRegistration({
    required String id,
    required String name,
    String? imageUrl,
    String? manufacturer,
    String? ingredient,
    String? dosage,
    required int dailyFrequency,
    required List<DosageTime> dosageTimes,
    required DateTime startDate,
    DateTime? endDate,
    @Default(false) bool isIndefinite,
    required RegistrationStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MedicationRegistration;

  factory MedicationRegistration.fromJson(Map<String, dynamic> json) =>
      _$MedicationRegistrationFromJson(json);
}

@freezed
class DosageTime with _$DosageTime {
  const factory DosageTime({
    required String id,
    required TimeOfDay time,
    required MealRelation mealRelation,
    required int mealOffsetMinutes,
  }) = _DosageTime;

  factory DosageTime.fromJson(Map<String, dynamic> json) =>
      _$DosageTimeFromJson(json);
}

@freezed
class TimeOfDay with _$TimeOfDay {
  const factory TimeOfDay({required int hour, required int minute}) =
      _TimeOfDay;

  factory TimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayFromJson(json);
}

enum MealRelation {
  before('식전'),
  after('식후'),
  anytime('상관없음');

  const MealRelation(this.label);
  final String label;
}

enum RegistrationStatus {
  draft('임시저장'),
  completed('등록완료');

  const RegistrationStatus(this.label);
  final String label;
}
