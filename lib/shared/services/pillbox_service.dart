import '../models/pillbox_model.dart';
import 'api_service.dart';

class PillboxService {
  final ApiService _apiService = apiService;

  /// 약상자 상태 조회
  Future<PillboxStatus?> getStatus() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/api/pillbox/status');
      if (response.data == null) return null;
      return PillboxStatus.fromJson(response.data!);
    } catch (e) {
      return null;
    }
  }

  /// 약상자 상태 설정
  Future<PillboxStatus> updateStatus(PillboxStatusUpdate update) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/pillbox/status',
        data: update.toJson(),
      );
      return PillboxStatus.fromJson(response.data!);
    } catch (e) {
      throw Exception('약상자 상태 설정 중 오류가 발생했습니다: $e');
    }
  }

  /// 약상자 감지 상태 업데이트
  Future<PillboxStatus> updateDetection(bool detected) async {
    return updateStatus(PillboxStatusUpdate(detected: detected));
  }

  /// 배터리 상태 업데이트
  Future<PillboxStatus> updateBattery(int batteryPercent) async {
    return updateStatus(PillboxStatusUpdate(batteryPercent: batteryPercent));
  }

  /// 잠금 상태 업데이트
  Future<PillboxStatus> updateLock(bool isLocked) async {
    return updateStatus(PillboxStatusUpdate(isLocked: isLocked));
  }
}

// 싱글톤 인스턴스
final PillboxService pillboxService = PillboxService();


