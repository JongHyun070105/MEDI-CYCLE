import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
// Open file is optional; fallback to no-op if unavailable
import '../../../../shared/services/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';

class AiFeedbackScreen extends StatelessWidget {
  const AiFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(children: [_MonthlyTab(), _WeekdayTab()]);
  }
}

class _MonthlyTab extends StatelessWidget {
  const _MonthlyTab();

  // 더미 데이터
  static const List<Map<String, dynamic>> _monthlyData = [
    {'month': '6월', 'rate': 53, 'color': Colors.orange},
    {'month': '7월', 'rate': 71, 'color': Colors.blue},
    {'month': '8월', 'rate': 89, 'color': AppColors.primary},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        100,
      ), // 하단 패딩 추가
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 월별 복용률 차트
          _buildMonthlyChart(),
          const SizedBox(height: AppSizes.xl),

          // AI 건강 인사이트
          _buildAiInsights(),
          const SizedBox(height: AppSizes.xl),

          // 리포트 생성 버튼
          _buildReportButton(context),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
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
          Text(
            '최근 3개월 약 복용률 (%)',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _monthlyData.map((data) {
                return _buildBarChart(
                  month: data['month'],
                  rate: data['rate'],
                  color: data['color'],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart({
    required String month,
    required int rate,
    required Color color,
  }) {
    final double height = (rate / 100) * 150;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$rate%',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          month,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
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

          // 복약 패턴 분석
          _buildInsightItem(
            title: '복약 패턴 분석',
            content:
                '주말 복약률이 평일보다 12% 낮습니다. 주말 알림을 좀 더 자주, 30분 일찍 설정하는 것을 권장합니다.',
            icon: Icons.analytics,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSizes.lg),

          // 의사 상담 준비사항
          _buildInsightItem(
            title: '의사 상담 준비사항',
            content: '혈압약 복용률 95% 달성. 다음 진료 시 용량 조절 상담을 받아보세요.',
            icon: Icons.medical_services,
            color: AppColors.success,
          ),
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
                    height: 1.4,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('의사 상담용 리포트를 생성 중입니다...'),
        backgroundColor: AppColors.primary,
      ),
    );
    _downloadAndOpenReport(context);
  }

  Future<void> _downloadAndOpenReport(BuildContext context) async {
    try {
      final uri = Uri.parse('http://localhost:3000/api/medications/report/pdf');
      final client = HttpClient();
      final req = await client.getUrl(uri);
      final token = await ApiClient().getToken();
      if (token != null) {
        req.headers.set('Authorization', 'Bearer $token');
      }
      final resp = await req.close();
      if (resp.statusCode != 200) {
        throw Exception('다운로드 실패(${resp.statusCode})');
      }

      final bytes = await consolidateHttpClientResponseBytes(resp);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/medicycle_report.pdf');
      await file.writeAsBytes(bytes, flush: true);

      // Try to open via platform channel if available; otherwise just notify path
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('리포트 저장됨: ${file.path}'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리포트 열기 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _WeekdayTab extends StatelessWidget {
  const _WeekdayTab();

  static const Map<String, double> _weekdayData = {'평일': 83.0, '주말': 78.0};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 평일/주말 복용률 차트
          _buildWeekdayChart(),
          const SizedBox(height: AppSizes.xl),

          // AI 건강 인사이트
          _buildAiInsights(),
        ],
      ),
    );
  }

  Widget _buildWeekdayChart() {
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
          Text(
            '평일, 주말 복용률 (%)',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: LineChartPainter(_weekdayData),
              child: Container(),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          // 범례
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('평일', Colors.blue),
              const SizedBox(width: AppSizes.lg),
              _buildLegendItem('주말', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
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

          // 복약 패턴 분석
          _buildInsightItem(
            title: '복약 패턴 분석',
            content:
                '주말 복약률이 평일보다 12% 낮습니다. 주말 알림을 좀 더 자주, 30분 일찍 설정하는 것을 권장합니다.',
            icon: Icons.analytics,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSizes.lg),

          // 의사 상담 준비사항
          _buildInsightItem(
            title: '의사 상담 준비사항',
            content: '혈압약 복용률 95% 달성. 다음 진료 시 용량 조절 상담을 받아보세요.',
            icon: Icons.medical_services,
            color: AppColors.success,
          ),
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
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 꺽은선 차트를 위한 CustomPainter
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
