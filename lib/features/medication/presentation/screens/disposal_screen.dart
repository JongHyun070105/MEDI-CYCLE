import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/services/kakao_places_service.dart';

class DisposalScreen extends StatelessWidget {
  final VoidCallback? onNavigateToHome;

  const DisposalScreen({super.key, this.onNavigateToHome});

  @override
  Widget build(BuildContext context) {
    final TabController? tabController = DefaultTabController.maybeOf(context);
    if (tabController == null) {
      // TabController가 없으면 (모달에서 직접 호출된 경우) DefaultTabController로 감싸기
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('폐의약품 처리'),
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: '가까운 수거함'),
                  Tab(text: '방문 수거 신청'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              const _NearbyDisposalTab(),
              _PickupRequestTab(onNavigateToHome: onNavigateToHome),
            ],
          ),
        ),
      );
    }
    // TabController가 있으면 (탭 내부에서 호출된 경우) TabBarView만 반환
    return TabBarView(
      children: [
        const _NearbyDisposalTab(),
        _PickupRequestTab(onNavigateToHome: onNavigateToHome),
      ],
    );
  }
}

class _NearbyDisposalTab extends StatefulWidget {
  const _NearbyDisposalTab();

  @override
  State<_NearbyDisposalTab> createState() => _NearbyDisposalTabState();
}

class _NearbyDisposalTabState extends State<_NearbyDisposalTab> {
  bool _isLoading = true;
  String? _error;
  Position? _pos;
  List<_PlaceView> _places = const [];
  List<_PlaceView> _allPlaces = const []; // 모든 장소 (필터링 전)
  StreamSubscription<Position>? _positionSub;
  String _category = 'all'; // 'all', 'pharmacy', 'health', 'hospital'

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = '위치 권한이 필요합니다.';
        });
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      await _updatePlacesForPosition(pos);

      _positionSub?.cancel();
      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(distanceFilter: 200),
          ).listen(
            (position) {
              _updatePlacesForPosition(position, fromStream: true);
            },
            onError: (error) {
              debugPrint('⚠️ 위치 스트림 에러: $error');
              // 에러가 발생해도 앱이 크래시되지 않도록 처리
              // 위치 서비스가 비활성화되거나 권한이 거부된 경우
            },
            cancelOnError: false,
          );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '위치 또는 장소 검색 실패: $e';
      });
    }
  }

  Future<void> _updatePlacesForPosition(
    Position pos, {
    bool fromStream = false,
  }) async {
    try {
      final double x = pos.longitude;
      final double y = pos.latitude;
      final results = await Future.wait<List<KakaoPlace>>([
        KakaoPlacesService.searchPlaces(query: '약국', x: x, y: y, radius: 3000),
        KakaoPlacesService.searchPlaces(query: '병원', x: x, y: y, radius: 3000),
        KakaoPlacesService.searchPlaces(query: '보건소', x: x, y: y, radius: 3000),
      ]);
      final Map<String, _PlaceView> merged = {};
      // 각 결과 리스트의 인덱스에 따라 타입 결정 (0: 약국, 1: 병원, 2: 보건소)
      for (int resultIndex = 0; resultIndex < results.length; resultIndex++) {
        final list = results[resultIndex];
        String defaultType;
        if (resultIndex == 0) {
          defaultType = '약국';
        } else if (resultIndex == 1) {
          defaultType = '병원';
        } else {
          defaultType = '보건소';
        }

        for (final p in list) {
          final double distance = Geolocator.distanceBetween(y, x, p.y, p.x);
          if (distance <= 3000) {
            // 카테고리가 비어있거나 정확히 일치하지 않으면 검색 쿼리 기준으로 타입 설정
            String placeType = defaultType;
            if (p.category != null && p.category!.isNotEmpty) {
              // 카테고리명이 정확히 일치하는 경우 사용
              if (p.category == '약국' ||
                  p.category == '병원' ||
                  p.category == '보건소') {
                placeType = p.category!;
              } else {
                // 일치하지 않으면 검색 쿼리 기준 사용
                placeType = defaultType;
              }
            }

            final view = _PlaceView(
              id: p.id,
              name: p.name,
              type: placeType,
              address: p.address,
              x: p.x,
              y: p.y,
              distanceMeters: distance,
            );
            if (!merged.containsKey(p.id) ||
                distance < merged[p.id]!.distanceMeters) {
              merged[p.id] = view;
            }
          }
        }
      }
      final list = merged.values.toList()
        ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      if (!mounted) return;
      setState(() {
        _pos = pos;
        _allPlaces = list;
        _places = _filterPlacesByCategory(list);
        _isLoading = false;
        _error = null;
      });
      if (fromStream) {
        debugPrint(
          '📍 위치 업데이트 (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}) - 결과 ${list.length}건',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '위치 또는 장소 검색 실패: $e';
      });
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return false;
    }
    return true;
  }

  List<_PlaceView> _filterPlacesByCategory(List<_PlaceView> places) {
    if (_category == 'all') {
      return places;
    }
    return places.where((place) {
      if (_category == 'pharmacy') {
        return place.type == '약국';
      } else if (_category == 'health') {
        return place.type == '보건소';
      } else if (_category == 'hospital') {
        return place.type == '병원';
      }
      return true;
    }).toList();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _category = category;
      _places = _filterPlacesByCategory(_allPlaces);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        150,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 필터
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Center(
              child: Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                alignment: WrapAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('전체'),
                    selected: _category == 'all',
                    onSelected: (_) => _onCategoryChanged('all'),
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _category == 'all'
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('약국'),
                    selected: _category == 'pharmacy',
                    onSelected: (_) => _onCategoryChanged('pharmacy'),
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _category == 'pharmacy'
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('보건소'),
                    selected: _category == 'health',
                    onSelected: (_) => _onCategoryChanged('health'),
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _category == 'health'
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('병원'),
                    selected: _category == 'hospital',
                    onSelected: (_) => _onCategoryChanged('hospital'),
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _category == 'hospital'
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_error != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_error!, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _init,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: const Text('다시 시도'),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    OutlinedButton(
                      onPressed: Geolocator.openAppSettings,
                      child: const Text('설정 열기'),
                    ),
                  ],
                ),
              ],
            )
          else if (_places.isEmpty)
            Text('주변 3km 내 결과가 없습니다.', style: AppTextStyles.bodyMedium)
          else
            Column(
              children: _places
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.md),
                      child: _buildDisposalLocationCard(
                        context: context,
                        name: p.name,
                        type: p.type,
                        address: p.address,
                        distance: (p.distanceMeters >= 1000
                            ? '${(p.distanceMeters / 1000).toStringAsFixed(1)}km'
                            : '${p.distanceMeters.toInt()}m'),
                        time: '',
                        onTap: () => _showRouteDialog(context, p),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDisposalLocationCard({
    required BuildContext context,
    required String name,
    required String type,
    required String address,
    required String distance,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              ),
              child: Icon(
                type == '병원'
                    ? Icons.local_hospital
                    : type == '약국'
                    ? Icons.local_pharmacy
                    : Icons.health_and_safety,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '$type · $address',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '$distance · $time',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.directions, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _showRouteDialog(BuildContext context, _PlaceView place) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${place.name} 길 안내'),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('카카오맵에서 길 안내를 시작할까요?'),
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        if (_pos == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('위치 정보를 가져올 수 없습니다.'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.fixed,
                            ),
                          );
                          return;
                        }
                        final double spLat = _pos!.latitude;
                        final double spLng = _pos!.longitude;
                        final String appUrl =
                            'kakaomap://route?sp=$spLat,$spLng&ep=${place.y},${place.x}&by=FOOT';
                        final String webUrl =
                            'https://map.kakao.com/link/to/${Uri.encodeComponent(place.name)},${place.y},${place.x}';
                        final Uri appUri = Uri.parse(appUrl);
                        final Uri webUri = Uri.parse(webUrl);
                        try {
                          if (await canLaunchUrl(appUri)) {
                            await launchUrl(appUri);
                          } else {
                            await launchUrl(
                              webUri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        } catch (_) {
                          await launchUrl(
                            webUri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: const Text('확인'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceView {
  final String id;
  final String name;
  final String type;
  final String address;
  final double x; // lon
  final double y; // lat
  final double distanceMeters;

  _PlaceView({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.x,
    required this.y,
    required this.distanceMeters,
  });
}

class _PickupRequestTab extends StatefulWidget {
  final VoidCallback? onNavigateToHome;

  const _PickupRequestTab({super.key, this.onNavigateToHome});

  @override
  State<_PickupRequestTab> createState() => _PickupRequestTabState();
}

class _PickupRequestTabState extends State<_PickupRequestTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTimeOfDay;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        150, // FAB와 겹치지 않도록 하단 패딩 추가
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '방문 수거 신청',
                        style: AppTextStyles.h6.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        '편리하게 방문 수거를 신청하세요',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // 신청자 정보
          _buildEditableInputField('연락처', _phoneController, '010-1234-5678'),
          const SizedBox(height: AppSizes.lg),

          // 수거 희망일
          _buildDateSelector(),
          const SizedBox(height: AppSizes.lg),

          // 수거 희망 시간
          _buildTimeSelector(),
          const SizedBox(height: AppSizes.xl),

          // 신청 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                splashFactory: NoSplash.splashFactory,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                elevation: 2,
              ),
              child: const Text(
                '수거 신청하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInputField(
    String label,
    TextEditingController controller,
    String hintText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.phone_android, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSizes.xs),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        TextField(
          controller: controller,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
          ),
          keyboardType: label == '연락처'
              ? TextInputType.phone
              : TextInputType.text,
          inputFormatters: label == '연락처'
              ? [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  LengthLimitingTextInputFormatter(11),
                ]
              : null,
          maxLength: label == '연락처' ? 11 : null,
          onChanged: (value) {
            if (label == '연락처' && value.length == 11) {
              FocusScope.of(context).unfocus();
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSizes.xs),
            Text(
              '수거 희망일',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _selectedDate != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일'
                      : '날짜를 선택하세요',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSizes.xs),
            Text(
              '수거 희망 시간',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: _selectedTimeOfDay != null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  _selectedTimeOfDay != null
                      ? '${_selectedTimeOfDay!.hour.toString().padLeft(2, '0')}:${_selectedTimeOfDay!.minute.toString().padLeft(2, '0')}'
                      : '시간을 선택하세요',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _selectedTimeOfDay != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    DateTime? picked;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // minimumDate와 initialDateTime을 동일한 값으로 설정하여 오류 방지
      final DateTime now = DateTime.now();
      final DateTime minimumDate = DateTime(now.year, now.month, now.day + 1);
      final DateTime maximumDate = DateTime(now.year, now.month, now.day + 30);
      DateTime selectedDate = minimumDate;
      picked = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (context) => Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      child: const Text('완료'),
                      onPressed: () {
                        Navigator.of(context).pop(selectedDate);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: minimumDate,
                    mode: CupertinoDatePickerMode.date,
                    minimumDate: minimumDate,
                    maximumDate: maximumDate,
                    use24hFormat: false,
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });
      }
    } else {
      picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now().add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 30)),
      );
      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked;
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      TimeOfDay selectedTimeOfDay = _selectedTimeOfDay ?? TimeOfDay.now();
      final DateTime now = DateTime.now();
      DateTime selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTimeOfDay.hour,
        selectedTimeOfDay.minute,
      );

      final DateTime? pickedDateTime = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (context) {
          DateTime tempDateTime = selectedDateTime;
          return Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        child: const Text('완료'),
                        onPressed: () {
                          Navigator.of(context).pop(tempDateTime);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      initialDateTime: selectedDateTime,
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime newDateTime) {
                        tempDateTime = newDateTime;
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (pickedDateTime != null) {
        picked = TimeOfDay(
          hour: pickedDateTime.hour,
          minute: pickedDateTime.minute,
        );
      }
    } else {
      picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
    }

    if (picked != null) {
      setState(() {
        _selectedTimeOfDay = picked;
      });
    }
  }

  void _submitRequest() {
    if (_phoneController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTimeOfDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 필드를 입력해주세요'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    // 입력 내용 초기화
    setState(() {
      _phoneController.clear();
      _selectedDate = null;
      _selectedTimeOfDay = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('수거 신청이 완료되었습니다'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.fixed,
        duration: Duration(seconds: 2),
      ),
    );

    // 홈 화면으로 이동
    widget.onNavigateToHome?.call();
  }
}
