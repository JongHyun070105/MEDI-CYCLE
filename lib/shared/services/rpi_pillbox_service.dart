import 'dart:convert';
import 'package:http/http.dart' as http;

/// 라즈베리파이 pillbox 서버 상태 모델
class RpiPillboxStatus {
  final bool hasMedication;
  final int? battery;
  final String? lastSeen;
  final bool isLocked;
  final bool forcedByExpiry;

  RpiPillboxStatus({
    required this.hasMedication,
    this.battery,
    this.lastSeen,
    required this.isLocked,
    required this.forcedByExpiry,
  });

  factory RpiPillboxStatus.fromJson(Map<String, dynamic> json) {
    return RpiPillboxStatus(
      hasMedication: json['hasMedication'] as bool? ?? false,
      battery: json['battery'] as int?,
      lastSeen: json['lastSeen'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      forcedByExpiry: json['forcedByExpiry'] as bool? ?? false,
    );
  }

  DateTime? get lastSeenDateTime {
    if (lastSeen == null) return null;
    try {
      return DateTime.parse(lastSeen!);
    } catch (e) {
      return null;
    }
  }

  String get lastSeenFormatted {
    final dt = lastSeenDateTime;
    if (dt == null) return '알 수 없음';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}초 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inDays}일 전';
    }
  }
}

/// 라즈베리파이 pillbox 서버 로그 모델
class RpiPillboxLog {
  final String ts;
  final bool hasMedication;
  final String note;

  RpiPillboxLog({
    required this.ts,
    required this.hasMedication,
    required this.note,
  });

  factory RpiPillboxLog.fromJson(Map<String, dynamic> json) {
    return RpiPillboxLog(
      ts: json['ts'] as String,
      hasMedication: json['hasMedication'] as bool? ?? false,
      note: json['note'] as String? ?? '',
    );
  }

  DateTime? get timestamp {
    try {
      return DateTime.parse(ts);
    } catch (e) {
      return null;
    }
  }

  String get timeFormatted {
    final dt = timestamp;
    if (dt == null) return '알 수 없음';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}초 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inDays}일 전';
    }
  }
}

/// 라즈베리파이 pillbox 서버 서비스
class RpiPillboxService {
  // 라즈베리파이 IP 주소 (같은 핫스팟에서 사용)
  // TODO: 나중에 설정으로 변경 가능하도록
  static const String _defaultRpiIp = '10.242.64.189';
  static const int _defaultPort = 8000;
  static const Duration _timeout = Duration(seconds: 5);

  String _rpiBaseUrl = 'http://$_defaultRpiIp:$_defaultPort';

  /// 라즈베리파이 IP 주소 설정
  void setRpiIp(String ip) {
    _rpiBaseUrl = 'http://$ip:$_defaultPort';
  }

  /// 서버 상태 확인 (헬스체크)
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_rpiBaseUrl/health'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 약상자 상태 조회
  Future<RpiPillboxStatus?> getStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_rpiBaseUrl/status'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RpiPillboxStatus.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 최근 활동 로그 조회
  Future<List<RpiPillboxLog>> getLogs({int limit = 100}) async {
    try {
      final response = await http
          .get(Uri.parse('$_rpiBaseUrl/logs?limit=$limit'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data
            .map((item) => RpiPillboxLog.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 연결 상태 확인 (서버가 응답하는지)
  Future<bool> isConnected() async {
    return await checkHealth();
  }

  /// 잠금 명령
  Future<bool> lock() async {
    try {
      final response = await http
          .post(Uri.parse('$_rpiBaseUrl/lock'))
          .timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 잠금 해제 명령 (강제잠금이면 423 반환 가능)
  Future<bool> unlock() async {
    try {
      final response = await http
          .post(Uri.parse('$_rpiBaseUrl/unlock'))
          .timeout(_timeout);
      if (response.statusCode == 200) return true;
      if (response.statusCode == 423) return false;
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 강제잠금 플래그 설정 (유통기한 만료)
  Future<bool> setExpiryForceLock(bool force) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_rpiBaseUrl/expiry/force-lock'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({"force": force}),
          )
          .timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 잠금 상태 조회
  Future<Map<String, dynamic>?> getLockStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_rpiBaseUrl/lock-status'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// 싱글톤 인스턴스
final RpiPillboxService rpiPillboxService = RpiPillboxService();
