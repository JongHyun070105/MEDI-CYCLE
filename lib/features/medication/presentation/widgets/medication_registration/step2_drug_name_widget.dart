import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../shared/services/drug_search_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../shared/services/ocr_service.dart';

class Step2DrugNameWidget extends StatefulWidget {
  final TextEditingController drugNameController;
  final Function(String) onDrugDetailsLoaded;

  const Step2DrugNameWidget({
    super.key,
    required this.drugNameController,
    required this.onDrugDetailsLoaded,
  });

  @override
  State<Step2DrugNameWidget> createState() => _Step2DrugNameWidgetState();
}

class _Step2DrugNameWidgetState extends State<Step2DrugNameWidget> {
  List<String> _filteredSuggestions = [];
  bool _isLoadingSuggestions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '약 이름을 입력해주세요',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSizes.lg),

        _buildDrugNameAutocomplete(),

        SizedBox(height: AppSizes.md),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickAndOcr,
              icon: const Icon(Icons.camera_alt),
              label: const Text('라벨 OCR로 채우기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                '사진의 약 라벨/상자를 촬영해 약명을 추출합니다.',
                softWrap: true,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrugNameAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.drugNameController,
          decoration: InputDecoration(
            labelText: '약 이름',
            hintText: '예: 타이레놀, 아스피린',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            prefixIcon: const Icon(Icons.medication),
            suffixIcon: _isLoadingSuggestions
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: _onDrugNameChanged,
        ),

        if (_filteredSuggestions.isNotEmpty) ...[
          SizedBox(height: AppSizes.sm),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(suggestion, style: AppTextStyles.bodySmall),
                  onTap: () async {
                    if (mounted) {
                      setState(() {
                        widget.drugNameController.text = suggestion;
                        _filteredSuggestions = [];
                      });
                    }

                    // 약 상세 정보 가져오기
                    await _loadDrugDetails(suggestion);
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _onDrugNameChanged(String value) async {
    if (value.length >= 2) {
      if (mounted) {
        setState(() {
          _isLoadingSuggestions = true;
        });
      }

      try {
        final suggestions = await DrugSearchService.searchDrugNames(value);
        if (mounted) {
          setState(() {
            _filteredSuggestions = suggestions.take(5).toList();
            _isLoadingSuggestions = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _filteredSuggestions = [];
            _isLoadingSuggestions = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _filteredSuggestions = [];
          _isLoadingSuggestions = false;
        });
      }
    }
  }

  Future<void> _loadDrugDetails(String drugName) async {
    try {
      final details = await DrugSearchService.getDrugDetails(drugName);
      if (details != null) {
        final manufacturer = details['entpName'] ?? '-';
        final ingredient = details['efcyQesitm'] ?? '-';

        widget.onDrugDetailsLoaded('$manufacturer|$ingredient');

        print('약 상세 정보 로드됨: 제조사=$manufacturer, 성분=$ingredient');
      }
    } catch (e) {
      print('약 상세 정보 로드 실패: $e');
      widget.onDrugDetailsLoaded('-|-');
    }
  }

  Future<void> _pickAndOcr() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (picked == null) return;
      final text = await ocrService.extractText(File(picked.path));
      final candidates = await ocrService.extractCandidateDrugNames(text);
      if (candidates.isNotEmpty && mounted) {
        setState(() {
          widget.drugNameController.text = candidates.first;
        });
        await _loadDrugDetails(candidates.first);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('텍스트에서 약명을 찾지 못했습니다.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('OCR 실패: $e')));
      }
    }
  }
}
