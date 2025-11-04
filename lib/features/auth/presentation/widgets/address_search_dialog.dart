import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/services/address_search_service.dart';

class AddressSearchDialog extends StatefulWidget {
  final Function(AddressResult) onAddressSelected;
  final String? initialQuery;

  const AddressSearchDialog({
    super.key,
    required this.onAddressSelected,
    this.initialQuery,
  });

  @override
  State<AddressSearchDialog> createState() => _AddressSearchDialogState();
}

class _AddressSearchDialogState extends State<AddressSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<AddressResult> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchAddress();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    if (_searchController.text.trim().isEmpty) {
      if (mounted) {
      setState(() {
        _searchResults = [];
      });
      }
      return;
    }

    if (mounted) {
    setState(() {
      _isLoading = true;
    });
    }

    try {
      final results = await AddressSearchService.searchAddress(
        _searchController.text.trim(),
      );
      if (mounted) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      }
    } catch (e) {
      if (mounted) {
      setState(() {
        _isLoading = false;
      });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주소 검색에 실패했습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.only(
          left: AppSizes.lg,
          right: AppSizes.lg,
          top: AppSizes.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              children: [
                Text(
                  '주소 검색',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            // 검색 입력 필드
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '예) 판교역로 235, 분당 주공, 삼평동 68',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          if (mounted) {
                          setState(() {
                            _searchResults = [];
                          });
                          }
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onChanged: (value) {
                if (mounted) {
                setState(() {});
                }
                if (value.length >= 2) {
                  _searchAddress();
                } else {
                  if (mounted) {
                  setState(() {
                    _searchResults = [];
                  });
                  }
                }
              },
              onSubmitted: (value) => _searchAddress(),
            ),

            const SizedBox(height: AppSizes.lg),

            // 검색 팁
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '검색 팁',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    '• 도로명 + 건물번호: 판교역로 235\n'
                    '• 지역명(동/리) + 번지: 삼평동 681\n'
                    '• 지역명(동/리) + 건물명: 분당 주공',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // 검색 결과
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            _searchController.text.isEmpty
                                ? '주소를 검색해주세요'
                                : '검색 결과가 없습니다',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return _buildAddressItem(result);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(AddressResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: AppColors.primary),
        title: Text(
          result.roadAddr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.jibunAddr.isNotEmpty)
              Text(
                '지번: ${result.jibunAddr}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            if (result.zipNo.isNotEmpty)
              Text(
                '우편번호: ${result.zipNo}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        onTap: () {
          widget.onAddressSelected(result);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
