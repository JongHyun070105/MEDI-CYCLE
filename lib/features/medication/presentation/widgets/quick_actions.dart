import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.qr_code_scanner,
                label: 'QR 스캔',
                color: AppColors.primary,
                onTap: () {
                  // TODO: QR 코드 스캔 화면으로 이동
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActionButton(
                icon: Icons.add,
                label: '약물 추가',
                color: AppColors.secondary,
                onTap: () {
                  // TODO: 약물 추가 화면으로 이동
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActionButton(
                icon: Icons.calendar_today,
                label: '복용 기록',
                color: AppColors.accent,
                onTap: () {
                  // TODO: 복용 기록 화면으로 이동
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.md),

        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.delete_outline,
                label: '폐의약품',
                color: AppColors.warning,
                onTap: () {
                  // TODO: 폐의약품 관리 화면으로 이동
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActionButton(
                icon: Icons.local_pharmacy,
                label: '근처 약국',
                color: AppColors.ecoBlue,
                onTap: () {
                  // TODO: 근처 약국 찾기 화면으로 이동
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActionButton(
                icon: Icons.eco,
                label: '환경 정보',
                color: AppColors.ecoGreen,
                onTap: () {
                  // TODO: 환경 정보 화면으로 이동
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, color: color, size: AppSizes.iconLg),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
