import '../models/medication_model.dart';
import 'api_service.dart';

class MedicationService {
  final ApiService _apiService = apiService;

  /// 복약 목록 조회
  Future<List<Medication>> getMedications() async {
    try {
      final response = await _apiService.get<List<dynamic>>('/api/medications');
      return response.data!
          .map((json) => Medication.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('복약 목록 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 복약 등록
  Future<Medication> createMedication(MedicationCreateRequest request) async {
    try {
      // 서버 스키마에 맞게 변환
      final int frequency = request.dailyCount;
      final List<String> dosageTimes = [
        if (request.time1 != null)
          '${request.time1!.hour.toString().padLeft(2, '0')}:${request.time1!.minute.toString().padLeft(2, '0')}',
        if (request.time2 != null)
          '${request.time2!.hour.toString().padLeft(2, '0')}:${request.time2!.minute.toString().padLeft(2, '0')}',
        if (request.time3 != null)
          '${request.time3!.hour.toString().padLeft(2, '0')}:${request.time3!.minute.toString().padLeft(2, '0')}',
        if (request.time4 != null)
          '${request.time4!.hour.toString().padLeft(2, '0')}:${request.time4!.minute.toString().padLeft(2, '0')}',
        if (request.time5 != null)
          '${request.time5!.hour.toString().padLeft(2, '0')}:${request.time5!.minute.toString().padLeft(2, '0')}',
        if (request.time6 != null)
          '${request.time6!.hour.toString().padLeft(2, '0')}:${request.time6!.minute.toString().padLeft(2, '0')}',
      ];

      final List<String> mealRelations = List.generate(
        frequency,
        (i) {
          final meals = [
            request.time1Meal,
            request.time2Meal,
            request.time3Meal,
            request.time4Meal,
            request.time5Meal,
            request.time6Meal,
          ];
          return meals.length > i && meals[i] != null ? meals[i]! : '';
        },
      );

      final List<int> mealOffsets = List.generate(
        frequency,
        (i) {
          final offsets = [
            request.time1OffsetMin,
            request.time2OffsetMin,
            request.time3OffsetMin,
            request.time4OffsetMin,
            request.time5OffsetMin,
            request.time6OffsetMin,
          ];
          return offsets.length > i && offsets[i] != null ? offsets[i]! : 0;
        },
      );

      final Map<String, dynamic> payload = {
        'drug_name': request.name,
        'frequency': frequency,
        'dosage_times': dosageTimes,
        'meal_relations': mealRelations,
        'meal_offsets': mealOffsets,
        'start_date': request.startDate.toIso8601String().split('T')[0],
        'end_date': request.endDate != null
            ? request.endDate!.toIso8601String().split('T')[0]
            : null,
        'is_indefinite': request.isIndefinite,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/medications',
        data: payload,
      );
      final Map<String, dynamic>? body = response.data;
      final Map<String, dynamic>? medicationJson =
          body != null ? body['medication'] as Map<String, dynamic>? : null;
      if (medicationJson == null) {
        throw Exception('약 등록 응답 형식이 올바르지 않습니다.');
      }
      return Medication.fromJson(medicationJson);
    } catch (e) {
      throw Exception('복약 등록 중 오류가 발생했습니다: $e');
    }
  }

  /// 복약 상세 조회
  Future<Medication> getMedication(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/medications/$id',
      );
      return Medication.fromJson(response.data!);
    } catch (e) {
      throw Exception('복약 정보 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 복약 수정
  Future<Medication> updateMedication(
    int id,
    MedicationUpdateRequest request,
  ) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/api/medications/$id',
        data: request.toJson(),
      );
      return Medication.fromJson(response.data!);
    } catch (e) {
      throw Exception('복약 수정 중 오류가 발생했습니다: $e');
    }
  }

  /// 복약 삭제
  Future<void> deleteMedication(int id) async {
    try {
      await _apiService.delete('/api/medications/$id');
    } catch (e) {
      throw Exception('복약 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 복용 시간 리스트를 서버 형식으로 변환
  static MedicationCreateRequest convertToServerFormat({
    required String drugName,
    required String frequency,
    required List<DateTime> dosageTimes,
    required List<String> mealRelations,
    required List<int> mealOffsets,
    required DateTime startDate,
    DateTime? endDate,
    required bool isIndefinite,
    String? manufacturer,
    String? ingredient,
    String? notes,
  }) {
    // 복용 시간을 서버 형식으로 변환
    Map<String, dynamic> data = {
      'name': drugName,
      'dailyCount': dosageTimes.length,
      'startDate': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD 형식
      'isIndefinite': isIndefinite,
    };

    // 복용 시간 정보 추가 (최대 6개)
    for (int i = 0; i < dosageTimes.length && i < 6; i++) {
      final time = dosageTimes[i];
      final mealRelation = mealRelations[i];
      final mealOffset = mealOffsets[i];

      data['time${i + 1}'] = {'hour': time.hour, 'minute': time.minute};
      data['time${i + 1}_meal'] = mealRelation;
      data['time${i + 1}_offset_min'] = mealOffset;
    }

    // 종료일 설정
    if (!isIndefinite && endDate != null) {
      data['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    // 메모에 제조사와 성분 정보 포함
    if (manufacturer != null || ingredient != null) {
      List<String> memoParts = [];
      if (manufacturer != null &&
          manufacturer.isNotEmpty &&
          manufacturer != '-') {
        memoParts.add('제조사: $manufacturer');
      }
      if (ingredient != null && ingredient.isNotEmpty && ingredient != '-') {
        memoParts.add('성분: $ingredient');
      }
      if (notes != null && notes.isNotEmpty) {
        memoParts.add('기타: $notes');
      }
      if (memoParts.isNotEmpty) {
        data['notes'] = memoParts.join('\n');
      }
    } else if (notes != null && notes.isNotEmpty) {
      data['notes'] = notes;
    }

    return MedicationCreateRequest.fromJson(data);
  }
}

// 싱글톤 인스턴스
final MedicationService medicationService = MedicationService();
