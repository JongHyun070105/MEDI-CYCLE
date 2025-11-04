import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
// Open file is optional; fallback to no-op if unavailable
import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/consent_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';

class AiFeedbackScreen extends StatefulWidget {
  const AiFeedbackScreen({super.key});

  @override
  State<AiFeedbackScreen> createState() => _AiFeedbackScreenState();
}

class _AiFeedbackScreenState extends State<AiFeedbackScreen> {
  bool _hasConsent = false;
  bool _isCheckingConsent = true;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final hasConsent = await consentService.hasConsentGiven();
    if (!hasConsent && mounted) {
      final result = await _showConsentDialog(context);
      if (result == true) {
        await consentService.setConsentGiven(true);
        if (mounted) {
          setState(() {
            _hasConsent = true;
            _isCheckingConsent = false;
          });
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _hasConsent = true;
          _isCheckingConsent = false;
        });
      }
    }
  }

  Future<bool?> _showConsentDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('AI 피드백 이용 동의'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 피드백 서비스를 이용하기 전에 다음 사항에 동의해주세요.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                '1. 개인정보 처리\n'
                '   - 복약 데이터는 AI 분석을 위해 사용됩니다.\n'
                '   - 분석 결과는 개인 식별 정보와 함께 저장되지 않습니다.\n\n'
                '2. 데이터 이용\n'
                '   - 복약 성실도 데이터는 통계 분석 목적으로만 사용됩니다.\n'
                '   - 서비스 개선을 위해 익명화된 데이터가 활용될 수 있습니다.\n\n'
                '3. 동의 철회\n'
                '   - 언제든지 설정에서 동의를 철회할 수 있습니다.\n'
                '   - 동의 철회 시 AI 피드백 서비스 이용이 제한됩니다.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('거부'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('동의'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingConsent) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasConsent) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSizes.lg),
            Text(
              'AI 피드백 서비스 이용을 위해\n이용 동의가 필요합니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            ElevatedButton(
              onPressed: _checkConsent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('동의하기'),
            ),
          ],
        ),
      );
    }

    return const TabBarView(children: [_DashboardTab(), _AiTab()]);
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _months = const [];
  List<Map<String, dynamic>> _weeklyData = const [];
  int _overallPct = 0;
  int _latestMonthPct = 0;
  int _previousMonthPct = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ApiClient();
      final insights = await api.getHealthInsights();
      final monthsRaw = List<Map<String, dynamic>>.from(insights['months'] ?? []);
      // 1~12월 고정 배열 생성 (기본 0%)
      final List<Map<String, dynamic>> months = List.generate(12, (i) {
        return {
          'month': (i + 1).toString().padLeft(2, '0'),
          'pct': 0,
        };
      });
      // 서버 값으로 덮기
      for (final m in monthsRaw) {
        final String raw = (m['month'] ?? '').toString();
        String mmStr;
        if (raw.contains('-') && raw.length >= 7) {
          mmStr = raw.substring(5, 7);
        } else if (raw.length >= 2) {
          mmStr = raw.substring(raw.length - 2);
        } else {
          mmStr = raw;
        }
        final int? mm = int.tryParse(mmStr);
        final int pct = int.tryParse(
              (m['pct'] ?? m['adherence_pct'] ?? 0).toString(),
            ) ??
            0;
        if (mm != null && mm >= 1 && mm <= 12) {
          months[mm - 1] = {'month': mmStr.padLeft(2, '0'), 'pct': pct};
        }
      }
      final int overall =
          int.tryParse((insights['overallPct'] ?? 0).toString()) ?? 0;
      final int latest = months.isNotEmpty ? months.last['pct'] as int : 0;
      final int previous = months.length > 1
          ? months[months.length - 2]['pct'] as int
          : latest;

      // 일주일 복용률 데이터 계산
      final DateTime today = DateTime.now();
      final DateTime weekAgo = today.subtract(const Duration(days: 6));
      final startOfWeek = DateTime(weekAgo.year, weekAgo.month, weekAgo.day);
      final endOfWeek = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final intakesResponse = await api.getMedicationIntakes(
        startDate: startOfWeek.toIso8601String(),
        endDate: endOfWeek.toIso8601String(),
      );
      final intakes = List<Map<String, dynamic>>.from(
        intakesResponse['intakes'] ?? [],
      );

      // 약 목록 조회 (계획된 복용 횟수 계산용)
      final medsResponse = await api.getMedications();
      final medications = List<Map<String, dynamic>>.from(
        medsResponse['medications'] ?? [],
      );

      // 일주일 데이터 계산 (월화수목금토일)
      final List<Map<String, dynamic>> weekly = [];
      final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dayOfWeek = date.weekday; // 1=월요일, 7=일요일
        final weekdayLabel = weekdays[dayOfWeek - 1];

        // 해당 날짜의 활성 약만 집계
        int planned = 0;
        for (final m in medications) {
          final String? startStr = (m['start_date'] ?? m['startDate'])?.toString();
          final String? endStr = (m['end_date'] ?? m['endDate'])?.toString();
          final bool isIndefinite = (m['is_indefinite'] ?? m['isIndefinite']) == true;
          if (startStr == null || startStr.isEmpty) continue;
          final DateTime? start = DateTime.tryParse(startStr);
          final DateTime? end = endStr != null && endStr.isNotEmpty
              ? DateTime.tryParse(endStr)
              : null;
          if (start == null) continue;
          final bool isActive = date.isAfter(start.subtract(const Duration(days: 1))) &&
              (isIndefinite || end == null || date.isBefore(end.add(const Duration(days: 1))));
          if (isActive) {
            planned += (m['dosage_times'] as List?)?.length ?? 0;
          }
        }

        // 해당 날짜의 완료된 복용 횟수
        final completed = intakes
            .where((it) {
              final intakeTime = DateTime.tryParse(it['intake_time']?.toString() ?? '');
              if (intakeTime == null) return false;
              return intakeTime.year == date.year &&
                  intakeTime.month == date.month &&
                  intakeTime.day == date.day &&
                  it['is_taken'] == true;
            })
            .length;

        final int pct = planned > 0 ? ((completed / planned) * 100).round() : 0;
        weekly.add({
          'day': weekdayLabel,
          'pct': pct,
          'planned': planned,
          'completed': completed,
        });
      }

      // 최근 3개월 평균 계산 (실제 최근 3개월 데이터 평균)
      int recent3MonthsSum = 0;
      int recent3MonthsCount = 0;
      if (months.length >= 3) {
        for (int i = months.length - 3; i < months.length; i++) {
          final pct = months[i]['pct'] as int;
          recent3MonthsSum += pct;
          recent3MonthsCount++;
        }
      }
      final int recent3MonthsAvg = recent3MonthsCount > 0
          ? (recent3MonthsSum / recent3MonthsCount).round()
          : overall;

      setState(() {
        _months = months;
        _weeklyData = weekly;
        _overallPct = recent3MonthsAvg;
        _latestMonthPct = latest;
        _previousMonthPct = previous;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _months = const [];
          _weeklyData = const [];
          _overallPct = 0;
          _latestMonthPct = 0;
          _previousMonthPct = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.xl * 2, // 하단 패딩 추가
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: AppSizes.md),
          _buildWeeklyChart(),
          const SizedBox(height: AppSizes.md),
          _buildMonthlyChart(),
          const SizedBox(height: AppSizes.xl), // 하단 여백 추가
        ],
      ),
    );

    return content;
  }

  Widget _buildSummaryCards() {
    final int diff = _latestMonthPct - _previousMonthPct;
    final String diffText = diff == 0
        ? '지난달과 동일'
        : diff > 0
            ? '+$diff% 상승'
            : '$diff% 감소';
    final Color diffColor =
        diff >= 0 ? AppColors.success : AppColors.error;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.show_chart,
            iconColor: AppColors.primary,
            title: '최근 3개월 평균',
            value: '$_overallPct%',
            subtitle: '전반적인 복약 성실도',
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.calendar_month,
            iconColor: AppColors.success,
            title: '이번 달 복약률',
            value: '$_latestMonthPct%',
            subtitle: diffText,
            subtitleColor: diffColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    Color? subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: subtitleColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.xs),
              Text(
                '월별 복용률 추이',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (_isLoading)
            const SizedBox.shrink() // 개별 로딩 인디케이터 제거
          else if (_months.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Text(
                '표시할 데이터가 없습니다.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: [
                // 차트 영역
                SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: _LineChartPainter(_months),
                    size: Size.infinite,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                // 월 레이블
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _months.map((m) {
                    final String month = (m['month'] ?? '').toString();
                    return Text(
                      _formatMonthLabel(month),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatMonthLabel(String month) {
    if (month.isEmpty) {
      return '';
    }
    if (month.length >= 7 && month[4] == '-') {
      final String mm = month.substring(
        5,
        month.length >= 7 ? 7 : month.length,
      );
      return mm;
    }
    if (month.length >= 2) {
      return month.substring(month.length - 2);
    }
    return month;
  }


  Widget _buildWeeklyChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_view_week, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSizes.xs),
              Text(
                '일주일 복용률',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (_isLoading)
            const SizedBox.shrink() // 개별 로딩 인디케이터 제거
          else if (_weeklyData.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Text(
                '표시할 데이터가 없습니다.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: [
                // 차트 영역
                SizedBox(
                  height: 180,
                  child: CustomPaint(
                    painter: _WeeklyChartPainter(_weeklyData),
                    size: Size.infinite,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                // 요일 레이블
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _weeklyData.map((d) {
                    final String day = (d['day'] ?? '').toString();
                    return Text(
                      day,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AiTab extends StatefulWidget {
  const _AiTab();

  @override
  State<_AiTab> createState() => _AiTabState();
}

class _AiTabState extends State<_AiTab> {
  bool _isLoading = true;
  String _message = '';
  List<String> _tips = const [];
  bool _isGeneratingReport = false;
  String? _lastReportPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ApiClient();
      final insights = await api.getHealthInsights();
      setState(() {
        _message = (insights['message'] ?? '').toString();
        _tips = List<String>.from(insights['tips'] ?? const []);
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _message = '';
          _tips = const [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAiInsights(),
          const SizedBox(height: AppSizes.xl),
          _buildReportSection(context),
          if (_lastReportPath != null) ...[
            const SizedBox(height: AppSizes.md),
            _buildReportSaveBanner(),
          ],
        ],
      ),
    );

    return Stack(
      children: [
        content,
        if (_isGeneratingReport)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: AppSizes.md),
                    Text(
                      '리포트를 생성 중입니다...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAiInsights() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSizes.sm),
              Text(
                'AI 건강 인사이트',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          if (_isLoading)
            const SizedBox.shrink() // 개별 로딩 인디케이터 제거
          else if (_message.isEmpty && _tips.isEmpty)
            Text(
              '표시할 인사이트가 없습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else ...[
            if (_message.isNotEmpty)
              _buildInsightItem(
                title: '요약',
                content: _message,
                icon: Icons.analytics,
                color: AppColors.primary,
              ),
            const SizedBox(height: AppSizes.lg),
            if (_tips.isNotEmpty)
              _buildInsightItem(
                title: '권장사항',
                content: _tips.join('\n'),
                icon: Icons.tips_and_updates,
                color: AppColors.success,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 24),
              const SizedBox(width: AppSizes.sm),
              Text(
                '의사 상담용 리포트',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            '최근 복약 내역과 성실도 추세를 정리한 PDF를 다운로드할 수 있습니다.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _buildReportButton(context),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Text(
                  content,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _generateReport(context),
        icon: const Icon(Icons.description),
        label: Text(
          '의사 상담용 리포트 생성하기',
          style: AppTextStyles.h6.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
    );
  }

  Widget _buildReportSaveBanner() {
    if (_lastReportPath == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.picture_as_pdf, color: AppColors.primary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PDF 보고서가 저장되었습니다.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  _lastReportPath!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('리포트 생성'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description, size: 64, color: AppColors.primary),
            SizedBox(height: AppSizes.md),
            Text(
              '의사 상담용 리포트를 생성하시겠습니까?\n\n복용률, 패턴 분석, 권장사항이 포함됩니다.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showReportGenerated(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              splashFactory: NoSplash.splashFactory,
            ),
            child: const Text('생성하기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showReportGenerated(BuildContext context) {
    setState(() {
      _isGeneratingReport = true;
      _lastReportPath = null;
    });
    _downloadAndOpenReport(context);
  }

  Future<void> _downloadAndOpenReport(BuildContext context) async {
    if (!context.mounted) return;
    
    try {
      debugPrint('📄 PDF report generation started. 요청 준비');
      final api = ApiClient();
      final response = await api.dio.get<List<int>>(
        '/api/medications/report/pdf',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('다운로드 실패(${response.statusCode})');
      }

      final bytes = response.data!;
      debugPrint('📄 PDF 데이터 수신 완료 (${bytes.length} bytes)');

      Directory? dir;
      String dirLabel = '저장 위치';
      if (Platform.isAndroid) {
        final candidates =
            await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (candidates != null && candidates.isNotEmpty) {
          dir = candidates.first;
          dirLabel = '다운로드 폴더';
        } else {
          dir = await getExternalStorageDirectory();
          dirLabel = '외부 저장소';
        }
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
        dirLabel = '문서 폴더';
      } else {
        dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        dirLabel = '다운로드 폴더';
      }
      dir ??= await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/yakdrugreport_$timestamp.pdf');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      debugPrint('📄 PDF 파일 저장 완료: ${file.path}');

      final Uri fileUri = Uri.file(file.path);
      bool opened = false;
      try {
        opened = await launchUrl(fileUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
      
      if (!context.mounted) return;
      setState(() {
        _isGeneratingReport = false;
        _lastReportPath = file.path;
      });
      
      final messenger = ScaffoldMessenger.of(context);
      if (opened) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('리포트를 열었습니다.'),
            backgroundColor: AppColors.primary,
          ),
        );
        debugPrint('📄 외부 앱에서 PDF를 열었습니다.');
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('리포트가 $dirLabel에 저장되었습니다.'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
          ),
        );
        debugPrint('📄 PDF 저장 후 수동 확인 필요.');
      }
    } catch (e) {
      debugPrint('❌ PDF 생성 중 오류: $e');
      if (!context.mounted) return;
      setState(() {
        _isGeneratingReport = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('리포트 생성 중 오류가 발생했습니다. 다시 시도해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// 월별 복용률 선 그래프를 위한 CustomPainter
class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> months;

  _LineChartPainter(this.months);

  @override
  void paint(Canvas canvas, Size size) {
    if (months.isEmpty) return;
    if (size.width <= 0 || size.height <= 0) return;

    final chartWidth = (size.width - 60).clamp(0.0, double.infinity);
    final chartHeight = (size.height - 40).clamp(0.0, double.infinity);
    
    if (chartWidth <= 0 || chartHeight <= 0) return;

    // 그리드 라인 그리기
    final gridPaint = Paint()
      ..color = AppColors.borderLight.withOpacity(0.5)
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = chartHeight * (i / 5) + 20;
      if (y.isFinite && y >= 0 && y <= size.height) {
        canvas.drawLine(Offset(40, y), Offset(size.width - 20, y), gridPaint);
      }
    }

    // 값 배열 (0~100으로 정규화 기준)
    final rates = months.map((m) {
      final int raw = int.tryParse((m['pct'] ?? m['adherence_pct'] ?? 0).toString()) ?? 0;
      return raw.clamp(0, 100);
    }).toList();

    if (rates.isEmpty) return;

    // 선 그래프 그리기
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final monthCount = months.length;
    final xDivisor = (monthCount > 1) ? (monthCount - 1) : 1;

    // 최소값, 최댓값, 중앙값 인덱스 찾기
    int minIndex = 0;
    int maxIndex = 0;
    final int medianIndex = monthCount ~/ 2;
    
    for (int i = 1; i < monthCount; i++) {
      if (rates[i] < rates[minIndex]) {
        minIndex = i;
      }
      if (rates[i] > rates[maxIndex]) {
        maxIndex = i;
      }
    }

    // 표시할 인덱스 집합 (최소값, 최댓값, 중앙값)
    final Set<int> labelIndices = {minIndex, maxIndex, medianIndex};

    for (int i = 0; i < monthCount; i++) {
      final rate = rates[i].toDouble();
      // 0~100 기준 고정 축 → 0.0~1.0로 정규화
      final normalizedRate = (rate / 100).clamp(0.0, 1.0);
      final x = 40 + chartWidth * (i / xDivisor);
      final y = 20 + chartHeight * (1 - normalizedRate);

      // NaN 체크
      if (!x.isFinite || !y.isFinite || x < 0 || y < 0 || x > size.width || y > size.height) {
        continue;
      }

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // 데이터 포인트 원 그리기
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // 최소값, 최댓값, 중앙값만 라벨 표시
      if (labelIndices.contains(i)) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$rate%',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textX = (x - textPainter.width / 2).clamp(0.0, size.width - textPainter.width);
        final textY = (y - 18).clamp(0.0, size.height);
        if (textX.isFinite && textY.isFinite) {
          textPainter.paint(canvas, Offset(textX, textY));
        }
      }
    }

    if (path.computeMetrics().isNotEmpty) {
      canvas.drawPath(path, linePaint);
    }

    // Y축 레이블 (0, 25, 50, 75, 100)
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final int value = i * 25;
      final labelY = 20 + chartHeight * (1 - (value / 100));

      if (!labelY.isFinite || labelY < 0 || labelY > size.height) {
        continue;
      }

      labelPainter.text = TextSpan(
        text: '$value%',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(5, labelY - 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 일주일 복용률 차트를 위한 CustomPainter
class _WeeklyChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> weeklyData;

  _WeeklyChartPainter(this.weeklyData);

  @override
  void paint(Canvas canvas, Size size) {
    if (weeklyData.isEmpty) return;
    if (size.width <= 0 || size.height <= 0) return;

    final chartWidth = (size.width - 60).clamp(0.0, double.infinity);
    final chartHeight = (size.height - 40).clamp(0.0, double.infinity);

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // 그리드 라인 그리기
    final gridPaint = Paint()
      ..color = AppColors.borderLight.withOpacity(0.5)
      ..strokeWidth = 1;

    // Y축 그리드 라인 (0%, 25%, 50%, 75%, 100%)
    for (int i = 0; i <= 4; i++) {
      final y = 20 + chartHeight * (i / 4);
      if (y.isFinite && y >= 0 && y <= size.height) {
        canvas.drawLine(Offset(40, y), Offset(size.width - 20, y), gridPaint);
      }
    }

    // 값 배열 (0~100으로 정규화 기준)
    final rates = weeklyData.map((d) {
      final int raw = int.tryParse((d['pct'] ?? 0).toString()) ?? 0;
      return raw.clamp(0, 100);
    }).toList();

    if (rates.isEmpty) return;

    // 선 그래프 그리기
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final dayCount = weeklyData.length;
    final xDivisor = (dayCount > 1) ? (dayCount - 1) : 1;

    // 최소값, 최댓값, 중앙값 인덱스 찾기
    int minIndex = 0;
    int maxIndex = 0;
    final int medianIndex = dayCount ~/ 2;

    for (int i = 1; i < dayCount; i++) {
      if (rates[i] < rates[minIndex]) {
        minIndex = i;
      }
      if (rates[i] > rates[maxIndex]) {
        maxIndex = i;
      }
    }

    // 표시할 인덱스 집합 (최소값, 최댓값, 중앙값)
    final Set<int> labelIndices = {minIndex, maxIndex, medianIndex};

    for (int i = 0; i < dayCount; i++) {
      final rate = rates[i].toDouble();
      // 0~100 기준 고정 축 → 0.0~1.0로 정규화
      final normalizedRate = (rate / 100).clamp(0.0, 1.0);
      final x = 40 + chartWidth * (i / xDivisor);
      final y = 20 + chartHeight * (1 - normalizedRate);

      // NaN 체크
      if (!x.isFinite || !y.isFinite || x < 0 || y < 0 || x > size.width || y > size.height) {
        continue;
      }

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // 데이터 포인트 원 그리기
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.white..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // 최소값, 최댓값, 중앙값만 라벨 표시
      if (labelIndices.contains(i)) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$rate%',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textX = (x - textPainter.width / 2).clamp(0.0, size.width - textPainter.width);
        final textY = (y - 18).clamp(0.0, size.height);
        if (textX.isFinite && textY.isFinite) {
          textPainter.paint(canvas, Offset(textX, textY));
        }
      }
    }

    if (path.computeMetrics().isNotEmpty) {
      canvas.drawPath(path, linePaint);
    }

    // Y축 레이블 (0, 25, 50, 75, 100)
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final int value = i * 25;
      final labelY = 20 + chartHeight * (1 - (value / 100));

      if (!labelY.isFinite || labelY < 0 || labelY > size.height) {
        continue;
      }

      labelPainter.text = TextSpan(
        text: '$value%',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(5, labelY - 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 평일/주말 차트를 위한 CustomPainter (사용하지 않음, 나중에 필요시 활용)
class LineChartPainter extends CustomPainter {
  final Map<String, double> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    // Y축 그리드 라인 그리기
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Y축 라벨과 그리드 라인
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 5; i++) {
      final y = (size.height - 40) * (i / 5) + 20;
      final value = (100 - i * 20).toString();

      // 그리드 라인
      canvas.drawLine(Offset(40, y), Offset(size.width - 20, y), gridPaint);

      // Y축 라벨
      textPainter.text = TextSpan(
        text: value,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 6));
    }

    // X축 라벨
    final xLabels = ['월', '화', '수', '목', '금', '토', '일'];
    for (int i = 0; i < xLabels.length; i++) {
      final x = 40 + (size.width - 60) * (i / (xLabels.length - 1));
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 15),
      );
    }

    // 데이터 포인트들 (7일간의 데이터)
    final weekdayPoints = [85.0, 82.0, 88.0, 90.0, 85.0, 78.0, 80.0];
    final weekendPoints = [75.0, 72.0, 78.0, 80.0, 75.0, 83.0, 85.0];

    // 평일 꺽은선 그리기
    final weekdayPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final weekdayPath = Path();
    for (int i = 0; i < weekdayPoints.length; i++) {
      final x = 40 + (size.width - 60) * (i / (weekdayPoints.length - 1));
      final y =
          (size.height - 40) -
          (weekdayPoints[i] / 100) * (size.height - 40) +
          20;

      if (i == 0) {
        weekdayPath.moveTo(x, y);
      } else {
        weekdayPath.lineTo(x, y);
      }
    }
    canvas.drawPath(weekdayPath, weekdayPaint);

    // 주말 꺽은선 그리기
    final weekendPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final weekendPath = Path();
    for (int i = 0; i < weekendPoints.length; i++) {
      final x = 40 + (size.width - 60) * (i / (weekendPoints.length - 1));
      final y =
          (size.height - 40) -
          (weekendPoints[i] / 100) * (size.height - 40) +
          20;

      if (i == 0) {
        weekendPath.moveTo(x, y);
      } else {
        weekendPath.lineTo(x, y);
      }
    }
    canvas.drawPath(weekendPath, weekendPaint);

    // 데이터 포인트 그리기
    final pointPaint = Paint()..style = PaintingStyle.fill;

    // 평일 점들
    pointPaint.color = Colors.blue;
    for (int i = 0; i < weekdayPoints.length; i++) {
      final x = 40 + (size.width - 60) * (i / (weekdayPoints.length - 1));
      final y =
          (size.height - 40) -
          (weekdayPoints[i] / 100) * (size.height - 40) +
          20;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }

    // 주말 점들
    pointPaint.color = AppColors.primary;
    for (int i = 0; i < weekendPoints.length; i++) {
      final x = 40 + (size.width - 60) * (i / (weekendPoints.length - 1));
      final y =
          (size.height - 40) -
          (weekendPoints[i] / 100) * (size.height - 40) +
          20;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
