import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medication_model.dart';
import '../../features/medication/presentation/widgets/medication_feedback_dialog.dart';
import 'navigation_service.dart';
import 'api_client.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🔔 알림 서비스 초기화 시작');

    // Android 초기화 설정
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // 초기화 설정
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 알림 플러그인 초기화
    final bool? initialized = await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('🔔 알림 플러그인 초기화 결과: $initialized');

    // Android 알림 채널 설정
    await _createNotificationChannel();

    // iOS 권한 확인 및 요청
    final bool? iosPermissionGranted = await _requestIOSPermissions();
    debugPrint('🔔 iOS 알림 권한 상태: $iosPermissionGranted');

    // Timezone 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    _isInitialized = true;
    debugPrint('🔔 알림 서비스 초기화 완료');
  }

  /// iOS 알림 권한 요청 (초기화 시 자동으로 요청됨)
  Future<bool?> _requestIOSPermissions() async {
    if (!Platform.isIOS) {
      return null;
    }

    // iOS에서는 initialize 시점에 requestAlertPermission: true로 설정하면
    // 자동으로 권한 요청 다이얼로그가 표시됩니다.
    // 여기서는 추가 확인만 수행합니다.
    debugPrint('🔔 iOS 알림 권한은 초기화 시 자동으로 요청됩니다.');
    return true;
  }

  /// Android 알림 채널 생성
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medication_reminders',
      '약 복용 알림',
      description: '약 복용 시간을 알려주는 알림입니다.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 알림 탭됨: ID=${response.id}, Payload=${response.payload}');

    // 알림 ID에서 약물 ID 추출 (알림 ID = medication.id * 100 + index)
    final int notificationId = response.id ?? 0;
    final int medicationId = notificationId ~/ 100;

    if (medicationId <= 0) {
      debugPrint('⚠️ 유효하지 않은 약물 ID: $medicationId');
      return;
    }

    // Payload에서 약물 이름과 시간 정보 추출
    String? medicationName;
    DateTime? scheduledTime;

    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        // Payload 형식: "medication_name|scheduled_time"
        final parts = response.payload!.split('|');
        if (parts.isNotEmpty) {
          medicationName = parts[0];
        }
        if (parts.length >= 2) {
          // scheduled_time을 DateTime으로 파싱
          final timeStr = parts[1];
          final timeParts = timeStr.split(':');
          if (timeParts.length >= 2) {
            final hour = int.tryParse(timeParts[0]);
            final minute = int.tryParse(timeParts[1]);
            if (hour != null && minute != null) {
              final now = DateTime.now();
              scheduledTime = DateTime(
                now.year,
                now.month,
                now.day,
                hour,
                minute,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Payload 파싱 오류: $e');
      }
    }

    // 기본값 설정
    medicationName ??= '약물';
    scheduledTime ??= DateTime.now();

    // 피드백 다이얼로그 표시 (context가 준비될 때까지 기다림)
    _showFeedbackDialogWithDelay(
      medicationId: medicationId,
      notificationId: notificationId,
      medicationName: medicationName,
      scheduledTime: scheduledTime,
    );
  }

  /// 피드백 다이얼로그 표시 (context가 준비될 때까지 기다림)
  void _showFeedbackDialogWithDelay({
    required int medicationId,
    required int notificationId,
    required String medicationName,
    required DateTime scheduledTime,
  }) {
    // 앱이 백그라운드에서 포그라운드로 전환될 때 context가 준비될 때까지 기다림
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 약간의 지연을 주어 context가 완전히 준비되도록 함
      Future.delayed(const Duration(milliseconds: 500), () {
        _showFeedbackDialog(
          medicationId: medicationId,
          notificationId: notificationId,
          medicationName: medicationName,
          scheduledTime: scheduledTime,
        );
      });
    });
  }

  /// 피드백 다이얼로그 표시
  void _showFeedbackDialog({
    required int medicationId,
    required int notificationId,
    required String medicationName,
    required DateTime scheduledTime,
  }) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) {
      debugPrint('⚠️ Navigator context가 없어 피드백 다이얼로그를 표시할 수 없습니다');
      // context가 없으면 다시 시도 (최대 3번)
      Future.delayed(const Duration(milliseconds: 300), () {
        final retryContext = NavigationService.navigatorKey.currentContext;
        if (retryContext != null) {
          MedicationFeedbackDialog.show(
            context: retryContext,
            medicationId: medicationId,
            notificationId: notificationId,
            medicationName: medicationName,
            scheduledTime: scheduledTime,
          );
        } else {
          debugPrint('⚠️ Navigator context를 가져올 수 없어 피드백 다이얼로그를 표시할 수 없습니다');
        }
      });
      return;
    }

    MedicationFeedbackDialog.show(
      context: context,
      medicationId: medicationId,
      notificationId: notificationId,
      medicationName: medicationName,
      scheduledTime: scheduledTime,
    );
  }

  /// 약 복용 알림 스케줄링
  Future<void> scheduleMedicationNotifications(Medication medication) async {
    if (!_isInitialized) {
      await initialize();
    }

    // iOS 권한 확인 (초기화 시 이미 요청했지만, 여기서도 재확인)
    if (Platform.isIOS) {
      debugPrint('🔔 iOS 알림 권한 재확인 중...');
      // iOS에서는 initialize 시점에 권한이 요청되므로
      // 여기서는 추가 확인만 수행
    }

    debugPrint('🔔 약 복용 알림 스케줄링 시작: ${medication.name}');

    // 약의 복용 기간 확인
    final DateTime now = DateTime.now();
    final DateTime startDate = DateTime(
      medication.startDate.year,
      medication.startDate.month,
      medication.startDate.day,
    );
    final DateTime? endDate = medication.endDate != null
        ? DateTime(
            medication.endDate!.year,
            medication.endDate!.month,
            medication.endDate!.day,
          )
        : null;

    // 복용 기간이 지나지 않았는지 확인
    final DateTime effectiveEndDate = endDate ?? DateTime(2100, 12, 31);
    if (now.isAfter(effectiveEndDate)) {
      return; // 종료일이 지났으면 알림 스케줄링하지 않음
    }

    // 시작일이 아직 오지 않았는지 확인
    if (now.isBefore(startDate)) {
      // 시작일이 미래이면 시작일부터 알림 스케줄링
      // (아래에서 처리)
    }

    // ML 서버에서 개인화된 스케줄 조회 시도
    Map<String, dynamic>? personalizedTimes;
    int? learningStage;
    try {
      final api = ApiClient();
      final scheduleResponse = await api.getPersonalizedSchedule(
        medicationType: medication.name,
      );
      final schedule = scheduleResponse['schedule'];
      if (schedule != null && schedule is Map<String, dynamic>) {
        final prediction = schedule['predicted_times'];
        learningStage = schedule['learning_stage'] as int?;
        if (prediction != null && prediction is Map<String, dynamic>) {
          personalizedTimes = prediction;
          debugPrint(
            '🤖 ML 서버 개인화 스케줄 조회 성공: ${medication.name}, 학습 단계: $learningStage',
          );
        }
      } else if (scheduleResponse['prediction'] != null) {
        // prediction이 직접 있는 경우
        final prediction =
            scheduleResponse['prediction'] as Map<String, dynamic>?;
        if (prediction != null) {
          learningStage = prediction['learning_stage'] as int?;
          final predictedTimes = prediction['predicted_times'];
          if (predictedTimes != null &&
              predictedTimes is Map<String, dynamic>) {
            personalizedTimes = predictedTimes;
            debugPrint(
              '🤖 ML 서버 개인화 스케줄 조회 성공 (직접): ${medication.name}, 학습 단계: $learningStage',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ ML 서버 개인화 스케줄 조회 실패: $e');
    }

    // 복용 시간 목록 가져오기
    final List<Map<String, dynamic>> dosageTimes = [];
    final List<Time?> times = [
      medication.time1,
      medication.time2,
      medication.time3,
      medication.time4,
      medication.time5,
      medication.time6,
    ];
    final List<String?> mealRelations = [
      medication.time1Meal,
      medication.time2Meal,
      medication.time3Meal,
      medication.time4Meal,
      medication.time5Meal,
      medication.time6Meal,
    ];
    final List<int?> mealOffsets = [
      medication.time1OffsetMin,
      medication.time2OffsetMin,
      medication.time3OffsetMin,
      medication.time4OffsetMin,
      medication.time5OffsetMin,
      medication.time6OffsetMin,
    ];

    // 학습 단계 2단계 이상이고 개인화된 시간이 있으면 사용
    bool usePersonalizedTime =
        learningStage != null &&
        learningStage >= 2 &&
        personalizedTimes != null;

    for (int i = 0; i < times.length; i++) {
      if (times[i] != null) {
        Time? timeToUse = times[i];

        // 개인화된 시간 사용 (아침/저녁 시간 기준으로 매핑)
        if (usePersonalizedTime) {
          if (i == 0 && personalizedTimes.containsKey('breakfast')) {
            // 첫 번째 시간을 아침 시간으로 매핑
            final breakfastTime = personalizedTimes['breakfast'] as String?;
            if (breakfastTime != null) {
              final parts = breakfastTime.split(':');
              if (parts.length == 2) {
                final hour = int.tryParse(parts[0]);
                final minute = int.tryParse(parts[1]);
                if (hour != null && minute != null) {
                  timeToUse = Time(hour: hour, minute: minute);
                  debugPrint('🤖 개인화된 아침 시간 사용: $breakfastTime');
                }
              }
            }
          } else if (i == times.length - 1 &&
              personalizedTimes.containsKey('dinner')) {
            // 마지막 시간을 저녁 시간으로 매핑
            final dinnerTime = personalizedTimes['dinner'] as String?;
            if (dinnerTime != null) {
              final parts = dinnerTime.split(':');
              if (parts.length == 2) {
                final hour = int.tryParse(parts[0]);
                final minute = int.tryParse(parts[1]);
                if (hour != null && minute != null) {
                  timeToUse = Time(hour: hour, minute: minute);
                  debugPrint('🤖 개인화된 저녁 시간 사용: $dinnerTime');
                }
              }
            }
          }
        }

        dosageTimes.add({
          'time': timeToUse!,
          'meal': mealRelations[i] ?? '',
          'offset': mealOffsets[i] ?? 0,
        });
      }
    }

    // 각 복용 시간에 대해 알림 스케줄링
    for (int i = 0; i < dosageTimes.length; i++) {
      final Time time = dosageTimes[i]['time'] as Time;
      final String mealRelation = dosageTimes[i]['meal'] as String;
      final int offset = dosageTimes[i]['offset'] as int;

      // 알림 시간 계산 (식전/식후와 간격 고려)
      DateTime notificationTime = _calculateNotificationTime(
        time,
        mealRelation,
        offset,
      );

      // 오늘 날짜 기준으로 알림 시간 설정
      final DateTime today = DateTime.now();
      final DateTime scheduledTime = DateTime(
        today.year,
        today.month,
        today.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      // 시작일이 미래라면 시작일부터 알림 시작
      DateTime firstNotificationDate = scheduledTime;
      if (startDate.isAfter(DateTime.now())) {
        firstNotificationDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          notificationTime.hour,
          notificationTime.minute,
        );
      }

      // 알림 ID 생성 (약 ID + 복용 시간 인덱스)
      final int notificationId = medication.id * 100 + i;

      // 약명 처리 (너무 길면 말줄임표)
      String medicationName = medication.name;
      const int maxTitleLength = 20;
      const int maxBodyLength = 30;
      String shortNameForTitle = medicationName.length > maxTitleLength
          ? '${medicationName.substring(0, maxTitleLength)}...'
          : medicationName;
      String shortNameForBody = medicationName.length > maxBodyLength
          ? '${medicationName.substring(0, maxBodyLength)}...'
          : medicationName;

      // 알림 내용 생성
      String mealText;
      String offsetText = '';
      if (offset > 0) {
        offsetText = ' $offset분';
      }

      if (mealRelation.isEmpty || mealRelation == '상관없음') {
        mealText = '약을 복용하실 시간입니다';
      } else if (mealRelation == '식전') {
        mealText = offset > 0 ? '식전$offsetText에 복용하실 시간입니다' : '식전에 복용하실 시간입니다';
      } else if (mealRelation == '식후') {
        mealText = offset > 0 ? '식후$offsetText에 복용하실 시간입니다' : '식후에 복용하실 시간입니다';
      } else if (mealRelation == '식중') {
        mealText = offset > 0
            ? '식사 중$offsetText에 복용하실 시간입니다'
            : '식사 중에 복용하실 시간입니다';
      } else {
        mealText = '약을 복용하실 시간입니다';
      }

      // 알림 제목 (약명이 길면 말줄임표)
      final String notificationTitle = '$shortNameForTitle 복용 시간';

      // 알림 내용 (약명 포함, 친절한 문구)
      final String notificationBody = '$shortNameForBody $mealText';

      // 첫 알림 시간이 현재 시간보다 이전이면 내일부터 시작
      final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(
        firstNotificationDate,
        tz.local,
      );
      final tz.TZDateTime nowTZDateTime = tz.TZDateTime.now(tz.local);

      tz.TZDateTime finalScheduledTime;
      if (scheduledTZDateTime.isBefore(nowTZDateTime)) {
        // 내일 같은 시간에 알림
        finalScheduledTime = nowTZDateTime.add(const Duration(days: 1));
        finalScheduledTime = tz.TZDateTime(
          finalScheduledTime.location,
          finalScheduledTime.year,
          finalScheduledTime.month,
          finalScheduledTime.day,
          notificationTime.hour,
          notificationTime.minute,
        );
      } else {
        finalScheduledTime = scheduledTZDateTime;
      }

      // 예약 알림 스케줄링 (매일 반복)
      debugPrint(
        '🔔 알림 스케줄링: ID=$notificationId, '
        '약명=${medication.name}, '
        '제목=$notificationTitle, '
        '시간=${finalScheduledTime.toString()}, '
        '내용=$notificationBody',
      );

      try {
        // iOS에서 알림 권한은 초기화 시 이미 요청됨
        if (Platform.isIOS) {
          debugPrint('✅ iOS 알림 권한 확인 (초기화 시 요청됨)');
        }

        // Payload에 약물 정보 저장 (알림 탭 시 사용)
        final String payload =
            '${medication.name}|${finalScheduledTime.hour.toString().padLeft(2, '0')}:${finalScheduledTime.minute.toString().padLeft(2, '0')}';

        await _notifications.zonedSchedule(
          notificationId,
          notificationTitle,
          notificationBody,
          finalScheduledTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_reminders',
              '약 복용 알림',
              channelDescription: '약 복용 시간을 알려주는 알림입니다.',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              largeIcon: const DrawableResourceAndroidBitmap('app_logo'),
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.active,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
        debugPrint('✅ 알림 스케줄링 성공: ID=$notificationId');

        // iOS에서 스케줄된 알림 확인 및 권한 재확인
        if (Platform.isIOS) {
          try {
            // 권한 상태 확인
            final NotificationAppLaunchDetails? launchDetails =
                await _notifications.getNotificationAppLaunchDetails();
            debugPrint(
              '🔔 iOS 알림 앱 실행 상태: ${launchDetails?.didNotificationLaunchApp}',
            );

            // 권한 상태 확인
            final bool? permissionStatus = await _notifications
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true);
            debugPrint('🔔 iOS 알림 권한 상태: $permissionStatus');

            final pendingNotifications = await _notifications
                .pendingNotificationRequests();
            final scheduled = pendingNotifications
                .where((n) => n.id == notificationId)
                .toList();
            if (scheduled.isNotEmpty) {
              debugPrint('✅ iOS 알림이 스케줄되었습니다: ID=$notificationId');
            } else {
              debugPrint('⚠️ iOS 알림이 스케줄되지 않았습니다: ID=$notificationId');
            }
          } catch (e) {
            debugPrint('⚠️ iOS 알림 확인 중 오류: $e');
          }
        }
      } catch (e) {
        debugPrint('❌ 알림 스케줄링 실패: ID=$notificationId, 오류=$e');
        rethrow;
      }
    }
    debugPrint('🔔 약 복용 알림 스케줄링 완료: ${medication.name}');
  }

  /// 알림 시간 계산 (식전/식후와 간격 고려)
  DateTime _calculateNotificationTime(
    Time time,
    String mealRelation,
    int offset,
  ) {
    // 기본 복용 시간
    DateTime notificationTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      time.hour,
      time.minute,
    );

    // 식전/식후와 간격에 따라 알림 시간 조정
    if (mealRelation == '식전') {
      // 식전: 복용 시간에서 간격만큼 빼기
      notificationTime = notificationTime.subtract(Duration(minutes: offset));
    } else if (mealRelation == '식후') {
      // 식후: 복용 시간에서 간격만큼 더하기
      notificationTime = notificationTime.add(Duration(minutes: offset));
    } else if (mealRelation == '식중') {
      // 식중: 복용 시간에서 간격만큼 빼기 (식사 중이므로 약간 이전에 알림)
      notificationTime = notificationTime.subtract(Duration(minutes: offset));
    }
    // 상관없음: 복용 시간에 알림

    return notificationTime;
  }

  /// 약 복용 알림 취소
  Future<void> cancelMedicationNotifications(int medicationId) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 해당 약의 모든 알림 취소 (약 ID * 100부터 약 ID * 100 + 99까지)
    for (int i = 0; i < 100; i++) {
      await _notifications.cancel(medicationId * 100 + i);
    }
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    await _notifications.cancelAll();
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int notificationId) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _notifications.cancel(notificationId);
  }
}

// 싱글톤 인스턴스
final NotificationService notificationService = NotificationService();
