import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/services/api_client.dart';

class MedicationStats extends StatefulWidget {
  const MedicationStats({super.key});

  @override
  State<MedicationStats> createState() => _MedicationStatsState();
}

class _MedicationStatsState extends State<MedicationStats> {
  int _uniqueMedications = 0; // unique count
  int _completedToday = 0;
  int _plannedToday = 0; // total planned intakes today (sum of times)
  double _progressPercentage = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final apiClient = ApiClient();

      // 약 목록 조회
      final medsResponse = await apiClient.getMedications();
      final medications = List<Map<String, dynamic>>.from(
        medsResponse['medications'] ?? [],
      );

      // 유니크 약물 수
      final Set<int> uniqueIds = medications.map((m) => m['id'] as int).toSet();
      final int uniqueCount = uniqueIds.length;

      // 오늘 계획된 복용 횟수 (빈 times 제외)
      int planned = 0;
      for (final m in medications) {
        planned += (m['dosage_times'] as List?)?.length ?? 0;
      }

      // 오늘의 복용 기록 조회
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final intakesResponse = await apiClient.getMedicationIntakes(
        startDate: startOfDay.toIso8601String(),
        endDate: endOfDay.toIso8601String(),
      );

      final intakes = List<Map<String, dynamic>>.from(
        intakesResponse['intakes'] ?? [],
      );

      // 완료 카운트 (true만)
      final int completed = intakes
          .where((it) => it['is_taken'] == true)
          .length;

      // 진행률 계산: 완료/계획
      final progress = planned > 0 ? completed / planned : 0.0;

      if (mounted) {
        setState(() {
          _uniqueMedications = uniqueCount;
          _plannedToday = planned;
          _completedToday = completed;
          _progressPercentage = progress.clamp(0.0, 1.0);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 통계 새로고침 (외부에서 호출 가능)
  Future<void> refreshStatistics() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await _loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: '총 약물',
                value: _uniqueMedications.toString(),
                icon: Icons.medication,
                color: AppColors.primary,
                subtitle: '개',
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _StatCard(
                title: '복용완료',
                value: '$_completedToday/$_plannedToday',
                icon: Icons.check_circle,
                color: AppColors.success,
                subtitle: '',
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.md),

        // 진행률 바
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오늘의 복용 진행률',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$_completedToday/$_plannedToday',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              LinearProgressIndicator(
                value: _progressPercentage,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconLg),
          const SizedBox(height: AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.h5.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
