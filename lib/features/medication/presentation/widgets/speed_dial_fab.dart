import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';

class SpeedDialFab extends StatefulWidget {
  final VoidCallback onRegisterPressed;
  final VoidCallback onSearchPressed;

  const SpeedDialFab({
    super.key,
    required this.onRegisterPressed,
    required this.onSearchPressed,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleRegister() {
    _toggle();
    Future.delayed(const Duration(milliseconds: 150), () {
      widget.onRegisterPressed();
    });
  }

  void _handleSearch() {
    _toggle();
    Future.delayed(const Duration(milliseconds: 150), () {
      widget.onSearchPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // 확장된 버튼들 (위로 수직 확장)
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            final double buttonHeight = 56.0;
            final double parentSpacing = 16.0; // 부모 FAB와 자식 버튼 간 간격
            final double childSpacing = 8.0; // 약 등록과 검색 버튼 간 간격
            final double registerButtonBottom = buttonHeight + parentSpacing; // 약 등록 버튼 (메인 버튼 위)
            final double searchButtonBottom = registerButtonBottom + childSpacing + buttonHeight; // 약 검색 버튼 (약 등록 버튼 위)

            return Stack(
              children: [
                // 약 검색 버튼 (위쪽)
                Positioned(
                  right: 0,
                  bottom: searchButtonBottom + (buttonHeight * (1 - _expandAnimation.value)),
                  child: Opacity(
                    opacity: _expandAnimation.value,
                    child: _buildPillButton(
                      icon: Icons.search,
                      label: '약 검색',
                      onPressed: _handleSearch,
                    ),
                  ),
                ),
                // 약 등록 버튼 (아래쪽)
                Positioned(
                  right: 0,
                  bottom: registerButtonBottom + (buttonHeight * (1 - _expandAnimation.value)),
                  child: Opacity(
                    opacity: _expandAnimation.value,
                    child: _buildPillButton(
                      icon: Icons.add,
                      label: '약 등록',
                      onPressed: _handleRegister,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        // 메인 버튼
        FloatingActionButton(
          heroTag: "main_fab",
          onPressed: _toggle,
          backgroundColor: AppColors.primary,
          elevation: 0,
          highlightElevation: 0,
          child: Icon(
            _isOpen ? Icons.close : Icons.more_vert,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPillButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(28),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AppColors.primary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSizes.xs),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
