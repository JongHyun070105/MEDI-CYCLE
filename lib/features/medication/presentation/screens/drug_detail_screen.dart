import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/services/drug_search_service.dart';

class DrugDetailScreen extends StatefulWidget {
  final String drugName;
  final Map<String, dynamic>? initialData;

  const DrugDetailScreen({
    super.key,
    required this.drugName,
    this.initialData,
  });

  @override
  State<DrugDetailScreen> createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  Map<String, dynamic>? _drugDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDrugDetails();
  }

  Future<void> _loadDrugDetails() async {
    if (widget.initialData != null) {
      // 초기 데이터가 있으면 상세 정보 조회
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final details = await DrugSearchService.getDrugDetails(widget.drugName);
      if (!mounted) return;

      if (details != null) {
        // 초기 데이터와 병합
        final merged = {
          ...?widget.initialData,
          ...details,
        };
        setState(() {
          _drugDetails = merged;
          _isLoading = false;
        });
      } else {
        // 상세 정보가 없으면 초기 데이터만 사용
        setState(() {
          _drugDetails = widget.initialData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '약 정보를 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('약 정보'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        _errorMessage!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : _drugDetails == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            '약 정보를 찾을 수 없습니다.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 약 이미지
                            _buildImageSection(),
                            // 기본 정보
                            _buildBasicInfoSection(),
                            // 효능·효과
                            _buildEfficacySection(),
                            // 용법·용량
                            _buildUsageSection(),
                            // 주의사항
                            _buildWarningSection(),
                            // 상호작용
                            _buildInteractionSection(),
                            // 부작용
                            _buildSideEffectSection(),
                            // 보관법
                            _buildStorageSection(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildImageSection() {
    final String? itemImage = _drugDetails!['itemImage'] as String?;
    final String itemName = _drugDetails!['itemName'] ?? widget.drugName;

    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.transparent,
      child: itemImage != null && itemImage.isNotEmpty
          ? Image.network(
              itemImage,
              width: double.infinity,
              height: 300,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return _buildPlaceholderImage(itemName);
              },
            )
          : _buildPlaceholderImage(itemName),
    );
  }

  Widget _buildPlaceholderImage(String itemName) {
    return Container(
      width: double.infinity,
      height: 300,
      color: AppColors.primary.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            itemName,
            style: AppTextStyles.h5,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final String itemName = _drugDetails!['itemName'] ?? widget.drugName;
    final String entpName = _drugDetails!['entpName'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemName,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (entpName.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              '제조사: $entpName',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String? content,
    IconData? icon,
  }) {
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSizes.xs),
              ],
              Text(
                title,
                style: AppTextStyles.h6.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            content,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEfficacySection() {
    final String? content = _drugDetails!['efcyQesitm'] as String?;
    return _buildSection(
      title: '효능·효과',
      content: content,
      icon: Icons.medical_services,
    );
  }

  Widget _buildUsageSection() {
    final String? content = _drugDetails!['useMethodQesitm'] as String?;
    return _buildSection(
      title: '용법·용량',
      content: content,
      icon: Icons.info_outline,
    );
  }

  Widget _buildWarningSection() {
    final String? warnContent = _drugDetails!['atpnWarnQesitm'] as String?;
    final String? atpnContent = _drugDetails!['atpnQesitm'] as String?;
    final List<String> parts = [];
    if (warnContent != null && warnContent.isNotEmpty) {
      parts.add(warnContent);
    }
    if (atpnContent != null && atpnContent.isNotEmpty) {
      parts.add(atpnContent);
    }
    final String combined = parts.join('\n\n');

    return _buildSection(
      title: '주의사항',
      content: combined.isEmpty ? null : combined,
      icon: Icons.warning_amber_rounded,
    );
  }

  Widget _buildInteractionSection() {
    final String? content = _drugDetails!['intrcQesitm'] as String?;
    return _buildSection(
      title: '상호작용',
      content: content,
      icon: Icons.sync_alt,
    );
  }

  Widget _buildSideEffectSection() {
    final String? content = _drugDetails!['seQesitm'] as String?;
    return _buildSection(
      title: '부작용',
      content: content,
      icon: Icons.error_outline,
    );
  }

  Widget _buildStorageSection() {
    final String? content = _drugDetails!['depositMethodQesitm'] as String?;
    return _buildSection(
      title: '보관법',
      content: content,
      icon: Icons.inventory_2_outlined,
    );
  }
}

