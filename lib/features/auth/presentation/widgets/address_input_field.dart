import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/services/address_search_service.dart';
import 'address_search_dialog.dart';

class AddressInputField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(AddressResult?)? onAddressSelected;

  const AddressInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.onAddressSelected,
  });

  @override
  State<AddressInputField> createState() => _AddressInputFieldState();
}

class _AddressInputFieldState extends State<AddressInputField> {
  AddressResult? _selectedAddress;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // 주소가 선택된 경우 입력을 막음
    if (_selectedAddress != null) {
      return;
    }

    if (widget.controller.text.length >= 2) {
      _getSuggestions();
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _selectedAddress = null;
      });
    }
  }

  Future<void> _getSuggestions() async {
    try {
      final suggestions = await AddressSearchService.getSuggestions(
        widget.controller.text,
      );
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
        });
      }
    } catch (e) {
      // 오류 발생 시 자동완성 숨김
      if (mounted) {
        setState(() {
          _showSuggestions = false;
        });
      }
    }
  }

  void _openAddressSearch() async {
    await showDialog<AddressResult>(
      context: context,
      builder: (context) => AddressSearchDialog(
        onAddressSelected: (address) {
          setState(() {
            _selectedAddress = address;
            widget.controller.text = address.roadAddr;
            _showSuggestions = false;
          });
          widget.onAddressSelected?.call(address);
        },
        initialQuery: widget.controller.text,
      ),
    );
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      widget.controller.text = suggestion;
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Text(
          widget.labelText,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppSizes.sm),

        // 주소 입력 필드
        Stack(
          children: [
            TextFormField(
              controller: widget.controller,
              readOnly: _selectedAddress != null,
              decoration: InputDecoration(
                hintText: widget.hintText ?? '주소를 검색해주세요',
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: IconButton(
                  onPressed: _openAddressSearch,
                  icon: const Icon(Icons.search),
                  color: AppColors.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                filled: false,
              ),
              validator: widget.validator,
              onTap: () {
                if (_selectedAddress != null) return;
                if (widget.controller.text.isEmpty) {
                  _openAddressSearch();
                }
              },
              onChanged: (value) {
                if (_selectedAddress != null) return;

                if (value.isEmpty) {
                  setState(() {
                    _selectedAddress = null;
                    _showSuggestions = false;
                  });
                } else if (value.length >= 2) {
                  _getSuggestions();
                }
              },
            ),

            // 자동완성 제안
            if (_showSuggestions && _suggestions.isNotEmpty)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ..._suggestions
                          .take(5)
                          .map(
                            (suggestion) => ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                suggestion,
                                style: AppTextStyles.bodySmall,
                              ),
                              onTap: () => _selectSuggestion(suggestion),
                            ),
                          ),
                      if (_suggestions.length > 5)
                        ListTile(
                          leading: const Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            '더 많은 결과 보기',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: _openAddressSearch,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        // 선택된 주소 정보
        if (_selectedAddress != null) ...[
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      '선택된 주소',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  _selectedAddress!.roadAddr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_selectedAddress!.jibunAddr.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '지번: ${_selectedAddress!.jibunAddr}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (_selectedAddress!.zipNo.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '우편번호: ${_selectedAddress!.zipNo}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
