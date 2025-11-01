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

    return const TabBarView(children: [_MonthlyTab(), _WeekdayTab()]);
  }
}

class _MonthlyTab extends StatefulWidget {
  const _MonthlyTab();

  @override
  State<_MonthlyTab> createState() => _MonthlyTabState();
}

class _MonthlyTabState extends State<_MonthlyTab> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _months = const [];
  String _message = '';
  List<String> _tips = const [];
  bool _isGeneratingReport = false;
  String? _lastReportPath;
  int _overallPct = 0;
  int _latestMonthPct = 0;
  int _previousMonthPct = 0;
  int _medicationCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ApiClient();
      final insights = await api.getHealthInsights();
      final medsResp = await api.getMedications();
      final monthsRaw = List<Map<String, dynamic>>.from(insights['months'] ?? []);
      final months = monthsRaw.map((m) {
        final int pct = int.tryParse(
              (m['pct'] ?? m['adherence_pct'] ?? 0).toString(),
            ) ??
            0;
        return {
          'month': m['month'],
          'pct': pct,
        };
      }).toList();
      final int overall =
          int.tryParse((insights['overallPct'] ?? 0).toString()) ?? 0;
      final int latest = months.isNotEmpty ? months.last['pct'] as int : 0;
      final int previous = months.length > 1
          ? months[months.length - 2]['pct'] as int
          : latest;
      final int medicationCount =
          (medsResp['medications'] as List<dynamic>? ?? const []).length;
      setState(() {
        _months = months;
        _message = (insights['message'] ?? '').toString();
        _tips = List<String>.from(insights['tips'] ?? const []);
        _overallPct = overall;
        _latestMonthPct = latest;
        _previousMonthPct = previous;
        _medicationCount = medicationCount;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _months = const [];
          _message = '';
          _tips = const [];
          _overallPct = 0;
          _latestMonthPct = 0;
          _previousMonthPct = 0;
          _medicationCount = 0;
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
          _buildSummaryHeader(),
          const SizedBox(height: AppSizes.xl),
          _buildMonthlyChart(),
          const SizedBox(height: AppSizes.xl),
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

  Widget _buildSummaryHeader() {
    final int diff = _latestMonthPct - _previousMonthPct;
    final String diffText = diff == 0
        ? '지난달과 동일'
        : diff > 0
            ? '+$diff% 상승'
            : '$diff% 감소';
    final Color diffColor =
        diff >= 0 ? AppColors.success : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복약 성실도 대시보드',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          '최근 복약 데이터를 기반으로 건강 인사이트를 제공합니다.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        Wrap(
          spacing: AppSizes.md,
          runSpacing: AppSizes.md,
          children: [
            _buildSummaryCard(
              icon: Icons.show_chart,
              iconColor: AppColors.primary,
              title: '최근 3개월 평균',
              value: '$_overallPct%',
              subtitle: '전반적인 복약 성실도',
            ),
            _buildSummaryCard(
              icon: Icons.calendar_month,
              iconColor: AppColors.success,
              title: '이번 달 복약률',
              value: '$_latestMonthPct%',
              subtitle: diffText,
              subtitleColor: diffColor,
            ),
            _buildSummaryCard(
              icon: Icons.medication,
              iconColor: AppColors.warning,
              title: '등록된 약',
              value: '$_medicationCount개',
              subtitle: '관리 중인 복약 스케줄',
            ),
          ],
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
      width: 200,
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_months.isEmpty)
            Text(
              '표시할 데이터가 없습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _months.map((m) {
                  final String month = (m['month'] ?? '').toString();
                  final int rate =
                      int.tryParse(
                        (m['pct'] ?? m['adherence_pct'] ?? 0).toString(),
                      ) ??
                      0;
                  final Color color = AppColors.primary;
                  return _buildBarChart(
                    month: _formatMonthLabel(month),
                    rate: rate,
                    color: color,
                  );
                }).toList(),
              ),
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
          if (_isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
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
      final file = File('${dir.path}/medicycle_report_$timestamp.pdf');
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
      if (context.mounted) {
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
              content: Text('리포트가 $dirLabel에 저장되었습니다.\n${file.path}'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 4),
            ),
          );
          debugPrint('📄 PDF 저장 후 수동 확인 필요.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isGeneratingReport = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('리포트를 열 수 없습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('❌ PDF 생성 중 오류: $e');
    }
  }
}

class _WeekdayTab extends StatefulWidget {
  const _WeekdayTab();

  @override
  State<_WeekdayTab> createState() => _WeekdayTabState();
}

class _WeekdayTabState extends State<_WeekdayTab> {
  bool _isLoading = true;
  int _overallPct = 0;
  List<String> _tips = const [];

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
        _overallPct =
            int.tryParse((insights['overallPct'] ?? 0).toString()) ?? 0;
        _tips = List<String>.from(insights['tips'] ?? const []);
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _overallPct = 0;
          _tips = const [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: AppSizes.xl),
          _buildAiInsights(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '최근 90일 전체 복용률',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_overallPct / 100).clamp(0.0, 1.0),
                        backgroundColor: AppColors.borderLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Text('$_overallPct%', style: AppTextStyles.h6),
                  ],
                ),
              ],
            ),
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
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_tips.isEmpty)
            Text(
              '표시할 인사이트가 없습니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            _buildInsightItem(
              title: '권장사항',
              content: _tips.join('\n'),
              icon: Icons.tips_and_updates,
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
