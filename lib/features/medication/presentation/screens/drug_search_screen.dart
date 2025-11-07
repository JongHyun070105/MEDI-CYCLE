import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/services/drug_search_service.dart';
import 'drug_detail_screen.dart';

class DrugSearchScreen extends StatefulWidget {
  const DrugSearchScreen({super.key});

  @override
  State<DrugSearchScreen> createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends State<DrugSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    if (value.isEmpty || value.length < 2) {
      setState(() {
        _searchResults.clear();
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(value);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await DrugSearchService.searchDrugsWithDetails(query);
      if (!mounted) return;
      setState(() {
        _searchResults.clear();
        _searchResults.addAll(results);
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('검색 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('약 검색'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '약 이름을 입력하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults.clear();
                            _hasSearched = false;
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              onChanged: _onSearchChanged,
              autofocus: true,
            ),
          ),
          // 검색 결과
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              '약 이름을 검색해보세요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
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
              '검색 결과가 없습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final drug = _searchResults[index];
        return _buildDrugCard(drug);
      },
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> drug) {
    final String itemName = drug['itemName'] ?? '';
    final String entpName = drug['entpName'] ?? '';
    final String itemImage = drug['itemImage'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DrugDetailScreen(
                drugName: itemName,
                initialData: drug,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              // 약 이미지
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: itemImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        child: Image.network(
                          itemImage,
                          width: 120,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Icon(
                              Icons.medication,
                              color: AppColors.primary,
                              size: 40,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.medication,
                        color: AppColors.primary,
                        size: 40,
                      ),
              ),
              const SizedBox(width: AppSizes.md),
              // 약 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: AppTextStyles.h6.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entpName.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        entpName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

