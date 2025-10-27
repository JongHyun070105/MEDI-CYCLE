import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../shared/services/drug_search_service.dart';

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
}
