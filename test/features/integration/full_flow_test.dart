import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:medi_cycle_app/shared/services/api_client.dart' as app;

const bool kUseLiveBackend = bool.fromEnvironment('USE_LIVE_BACKEND');

void main() {
  group('Integration > Auth → Medication → Intake → Stats → Report', () {
    late app.ApiClient api;
    late Dio raw;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      api = app.ApiClient();
      await api.initializePrefs();
      raw = api.dio;

      // Mock network via Dio interceptor (disabled when USE_LIVE_BACKEND=true)
      if (!kUseLiveBackend) {
        api.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final path = options.path;
              final method = options.method.toUpperCase();
              Map<String, dynamic> json({required Object? data}) =>
                  data as Map<String, dynamic>;

              if (method == 'POST' && path.endsWith('/api/auth/register')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {"message": "ok"},
                    statusCode: 200,
                  ),
                );
              }
              if (method == 'POST' && path.endsWith('/api/auth/login')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      "token": "mock-token",
                      "user": {
                        "id": 1,
                        "email": "test@ex.com",
                        "name": "Tester",
                      },
                    },
                    statusCode: 200,
                  ),
                );
              }
              if (method == 'PUT' && path.endsWith('/api/auth/profile')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {"ok": true},
                    statusCode: 200,
                  ),
                );
              }
              if (method == 'POST' && path.endsWith('/api/medications')) {
                final now = DateTime.now().toIso8601String();
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      "message": "약이 등록되었습니다",
                      "medication": {
                        "id": 1,
                        "drug_name": json(data: options.data)["drug_name"],
                        "frequency": json(data: options.data)["frequency"],
                        "dosage_times": json(
                          data: options.data,
                        )["dosage_times"],
                        "start_date": json(data: options.data)["start_date"],
                        "end_date": json(data: options.data)["end_date"],
                        "created_at": now,
                      },
                    },
                    statusCode: 201,
                  ),
                );
              }
              if (method == 'POST' &&
                  path.endsWith('/api/medications/intake/record')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      "message": "복용 기록이 저장되었습니다",
                      "intake": {"id": 1, "is_taken": true},
                    },
                    statusCode: 201,
                  ),
                );
              }
              if (method == 'GET' &&
                  path.contains('/api/medications/intake/list')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      "intakes": [
                        {
                          "id": 1,
                          "is_taken": true,
                          "intake_time": DateTime.now().toIso8601String(),
                        },
                      ],
                    },
                    statusCode: 200,
                  ),
                );
              }
              if (method == 'GET' &&
                  path.endsWith('/api/medications/stats/adherence/monthly')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      "months": [
                        {
                          "month": "2025-08",
                          "planned": 10,
                          "completed": 7,
                          "adherence_pct": 70,
                        },
                        {
                          "month": "2025-09",
                          "planned": 12,
                          "completed": 9,
                          "adherence_pct": 75,
                        },
                        {
                          "month": "2025-10",
                          "planned": 15,
                          "completed": 13,
                          "adherence_pct": 87,
                        },
                      ],
                    },
                    statusCode: 200,
                  ),
                );
              }
              if (method == 'GET' &&
                  path.endsWith('/api/medications/report/pdf')) {
                // Return a minimal valid PDF header
                final bytes = '%PDF-1.4\n%Mock'.codeUnits;
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    data: bytes,
                    statusCode: 200,
                    headers: Headers.fromMap({
                      'content-type': ['application/pdf'],
                    }),
                  ),
                );
              }

              // Fallback: prevent real network
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'No mock for $method $path',
                ),
              );
            },
          ),
        );
      }
    });

    test(
      'Full flow works end-to-end (requires backend running at localhost:3000)',
      () async {
        // Arrange: user credentials
        final String email =
            'it_${DateTime.now().microsecondsSinceEpoch}@ex.com';
        const String password = 'test1234!';
        const String name = 'Integration User';

        // Act: register or login
        Map<String, dynamic> loginResp;
        try {
          await api.register(email: email, password: password, name: name);
          loginResp = await api.login(email: email, password: password);
        } catch (_) {
          // if already exists
          loginResp = await api.login(email: email, password: password);
        }

        // Save token for subsequent calls
        final String token =
            (loginResp['token'] ?? loginResp['accessToken']) as String;
        await api.saveToken(token);

        // Profile update
        final prof = await api.updateProfile(
          age: 29,
          address: 'Seoul',
          gender: '남성',
        );
        expect(prof, isA<Map<String, dynamic>>());

        // Medication register
        final today = DateTime.now();
        final String ymd =
            '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final reg = await api.registerMedication(
          drugName: '아스피린 ${Random().nextInt(9999)}',
          manufacturer: '테스트제약',
          ingredient: '성분',
          frequency: 2,
          dosageTimes: ['08:00', '20:00'],
          mealRelations: ['식후', '식후'],
          mealOffsets: [30, 30],
          startDate: ymd,
          endDate: ymd,
          isIndefinite: false,
        );
        final med = reg['medication'] as Map<String, dynamic>;
        final int medId = med['id'] as int;
        expect(medId, greaterThan(0));

        // Intake record
        final rec = await api.recordMedicationIntake(
          medicationId: medId,
          intakeTime: DateTime.now().toIso8601String(),
          isTaken: true,
        );
        expect(rec['intake'], isNotNull);

        // Daily intakes fetch
        final startDay = DateTime(
          today.year,
          today.month,
          today.day,
        ).toIso8601String();
        final endDay = DateTime(
          today.year,
          today.month,
          today.day,
          23,
          59,
          59,
        ).toIso8601String();
        final list = await api.getMedicationIntakes(
          startDate: startDay,
          endDate: endDay,
        );
        expect(list['intakes'], isA<List<dynamic>>());

        // Monthly stats
        final stats = await api.getMonthlyAdherenceStats();
        expect(stats['months'], isA<List<dynamic>>());

        // Report PDF (bytes)
        final resp = await raw.get(
          '/api/medications/report/pdf',
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
        expect(resp.statusCode, 200);
        final contentType = resp.headers['content-type']?.join(',') ?? '';
        expect(contentType.contains('application/pdf'), true);
        // sanity check: PDF header %PDF-
        final bytes = resp.data as List<int>;
        final header = utf8.decode(
          bytes.take(5).toList(),
          allowMalformed: true,
        );
        expect(header.startsWith('%PDF-'), true);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
