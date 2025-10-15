import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_model.freezed.dart';
part 'medication_model.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication({
    required int id,
    required int userId,
    required String name,
    required int dailyCount,
    
    // 복용 시간 정보 (최대 6개)
    Time? time1,
    String? time1Meal,
    int? time1OffsetMin,
    Time? time2,
    String? time2Meal,
    int? time2OffsetMin,
    Time? time3,
    String? time3Meal,
    int? time3OffsetMin,
    Time? time4,
    String? time4Meal,
    int? time4OffsetMin,
    Time? time5,
    String? time5Meal,
    int? time5OffsetMin,
    Time? time6,
    String? time6Meal,
    int? time6OffsetMin,
    
    required DateTime startDate,
    DateTime? endDate,
    required bool isIndefinite,
    String? notes,
    
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Medication;

  factory Medication.fromJson(Map<String, dynamic> json) => 
      _$MedicationFromJson(json);
}

@freezed
class Time with _$Time {
  const factory Time({
    required int hour,
    required int minute,
  }) = _Time;

  factory Time.fromJson(Map<String, dynamic> json) => _$TimeFromJson(json);
  
  // DateTime을 Time으로 변환
  factory Time.fromDateTime(DateTime dateTime) => Time(
    hour: dateTime.hour,
    minute: dateTime.minute,
  );

  // 서버 형식에서 생성
  factory Time.fromServerFormat(String timeString) {
    final parts = timeString.split(':');
    return Time(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

// Time 확장 클래스
extension TimeExtension on Time {
  // Time을 DateTime으로 변환 (오늘 날짜 기준)
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // 서버 형식으로 변환 (HH:MM:SS)
  String toServerFormat() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
  }
}

@freezed
class MedicationCreateRequest with _$MedicationCreateRequest {
  const factory MedicationCreateRequest({
    required String name,
    required int dailyCount,
    
    Time? time1,
    String? time1Meal,
    int? time1OffsetMin,
    Time? time2,
    String? time2Meal,
    int? time2OffsetMin,
    Time? time3,
    String? time3Meal,
    int? time3OffsetMin,
    Time? time4,
    String? time4Meal,
    int? time4OffsetMin,
    Time? time5,
    String? time5Meal,
    int? time5OffsetMin,
    Time? time6,
    String? time6Meal,
    int? time6OffsetMin,
    
    required DateTime startDate,
    DateTime? endDate,
    @Default(false) bool isIndefinite,
    String? notes,
  }) = _MedicationCreateRequest;

  factory MedicationCreateRequest.fromJson(Map<String, dynamic> json) => 
      _$MedicationCreateRequestFromJson(json);
}

@freezed
class MedicationUpdateRequest with _$MedicationUpdateRequest {
  const factory MedicationUpdateRequest({
    String? name,
    int? dailyCount,
    
    Time? time1,
    String? time1Meal,
    int? time1OffsetMin,
    Time? time2,
    String? time2Meal,
    int? time2OffsetMin,
    Time? time3,
    String? time3Meal,
    int? time3OffsetMin,
    Time? time4,
    String? time4Meal,
    int? time4OffsetMin,
    Time? time5,
    String? time5Meal,
    int? time5OffsetMin,
    Time? time6,
    String? time6Meal,
    int? time6OffsetMin,
    
    DateTime? startDate,
    DateTime? endDate,
    bool? isIndefinite,
    String? notes,
  }) = _MedicationUpdateRequest;

  factory MedicationUpdateRequest.fromJson(Map<String, dynamic> json) => 
      _$MedicationUpdateRequestFromJson(json);
}
