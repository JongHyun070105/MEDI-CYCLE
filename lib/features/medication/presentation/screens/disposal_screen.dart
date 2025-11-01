import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/services/kakao_places_service.dart';

class DisposalScreen extends StatelessWidget {
  const DisposalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [_NearbyDisposalTab(), _MapViewTab(), _PickupRequestTab()],
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
  StreamSubscription<Position>? _positionSub;

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
          ).listen((position) {
            _updatePlacesForPosition(position, fromStream: true);
          });
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
      for (final list in results) {
        for (final p in list) {
          final double distance = Geolocator.distanceBetween(y, x, p.y, p.x);
          if (distance <= 3000) {
            final view = _PlaceView(
              id: p.id,
              name: p.name,
              type: (p.category ?? '').isEmpty ? '시설' : p.category!,
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
        _places = list;
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

  @override
  Widget build(BuildContext context) {
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
          Text(
            '가까운 폐의약품 수거처(3km)',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_error != null)
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
          content: const Text('카카오맵에서 길 안내를 시작할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (_pos == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('위치 정보를 가져올 수 없습니다.'),
                      backgroundColor: Colors.red,
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
                  await launchUrl(webUri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Text('확인'),
            ),
          ],
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

class _MapViewTab extends StatelessWidget {
  const _MapViewTab();

  @override
  Widget build(BuildContext context) {
    return const _KakaoMapView();
  }
}

class _KakaoMapView extends StatefulWidget {
  const _KakaoMapView();

  @override
  State<_KakaoMapView> createState() => _KakaoMapViewState();
}

class _KakaoMapViewState extends State<_KakaoMapView> {
  bool _isLoading = true;
  String? _error;
  Position? _pos;
  List<_PlaceView> _places = const [];
  String _category = 'all';
  String? _selectedPlaceId;
  StreamSubscription<Position>? _positionSub;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  Future<void> _loadPlaces({bool forceLocate = false}) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = '위치 권한이 필요합니다.';
        });
        return;
      }

      Position pos;
      if (!forceLocate && _pos != null) {
        pos = _pos!;
      } else {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
      }

      await _updatePlacesForPosition(pos, keepSelection: !forceLocate);

      _positionSub ??=
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(distanceFilter: 200),
          ).listen((position) {
            _updatePlacesForPosition(position, fromStream: true);
          });
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
    bool keepSelection = false,
  }) async {
    try {
      final double x = pos.longitude, y = pos.latitude;
      final queries = <Future<List<KakaoPlace>>>[];
      if (_category == 'all' || _category == 'pharmacy') {
        queries.add(KakaoPlacesService.searchPlaces(query: '약국', x: x, y: y));
      }
      if (_category == 'all' || _category == 'hospital') {
        queries.add(KakaoPlacesService.searchPlaces(query: '병원', x: x, y: y));
      }
      if (_category == 'all' || _category == 'health') {
        queries.add(KakaoPlacesService.searchPlaces(query: '보건소', x: x, y: y));
      }

      final results = await Future.wait(queries);
      final Map<String, _PlaceView> merged = {};
      for (final list in results) {
        for (final p in list) {
          final d = Geolocator.distanceBetween(y, x, p.y, p.x);
          if (d <= 3000) {
            final view = _PlaceView(
              id: p.id,
              name: p.name,
              type: (p.category ?? '').isEmpty ? '시설' : p.category!,
              address: p.address,
              x: p.x,
              y: p.y,
              distanceMeters: d,
            );
            if (!merged.containsKey(p.id) || d < merged[p.id]!.distanceMeters) {
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
        _places = list;
        _isLoading = false;
        if (_places.isNotEmpty) {
          if (!keepSelection ||
              _selectedPlaceId == null ||
              !_places.any((p) => p.id == _selectedPlaceId)) {
            _selectedPlaceId = _places.first.id;
          }
        } else {
          _selectedPlaceId = null;
        }
        _error = null;
      });

      if (fromStream) {
        debugPrint(
          '🗺️ 위치 스트림 업데이트 (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}) - ${list.length}건',
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

  _PlaceView? get _selectedPlace {
    if (_selectedPlaceId == null) return null;
    for (final p in _places) {
      if (p.id == _selectedPlaceId) return p;
    }
    return null;
  }

  String? get _staticMapUrl {
    final double? centerLat = _selectedPlace?.y ?? _pos?.latitude;
    final double? centerLng = _selectedPlace?.x ?? _pos?.longitude;
    if (centerLat == null || centerLng == null) return null;

    final markers = <String>[];
    if (_pos != null) {
      markers.add(
        'type:blue|size:small|pos:${_pos!.longitude},${_pos!.latitude}',
      );
    }
    if (_selectedPlace != null) {
      markers.add(
        'type:red|size:mid|pos:${_selectedPlace!.x},${_selectedPlace!.y}',
      );
    } else {
      for (final place in _places.take(3)) {
        markers.add('type:red|size:small|pos:${place.x},${place.y}');
      }
    }

    final level = _selectedPlace != null ? 4 : 5;
    return KakaoPlacesService.buildStaticMapUrl(
      lat: centerLat,
      lng: centerLng,
      markers: markers,
      level: level,
      width: 720,
      height: 360,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Wrap(
            spacing: AppSizes.sm,
            children: [
              ChoiceChip(
                label: const Text('전체'),
                selected: _category == 'all',
                onSelected: (_) {
                  setState(() => _category = 'all');
                  _loadPlaces();
                },
              ),
              ChoiceChip(
                label: const Text('약국'),
                selected: _category == 'pharmacy',
                onSelected: (_) {
                  setState(() => _category = 'pharmacy');
                  _loadPlaces();
                },
              ),
              ChoiceChip(
                label: const Text('병원'),
                selected: _category == 'hospital',
                onSelected: (_) {
                  setState(() => _category = 'hospital');
                  _loadPlaces();
                },
              ),
              ChoiceChip(
                label: const Text('보건소'),
                selected: _category == 'health',
                onSelected: (_) {
                  setState(() => _category = 'health');
                  _loadPlaces();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: () => _loadPlaces(forceLocate: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      left: AppSizes.md,
                      right: AppSizes.md,
                      bottom: AppSizes.xl,
                    ),
                    itemCount: _places.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildStaticMapCard();
                      }
                      final place = _places[index - 1];
                      return _buildPlaceTile(place);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _error ?? '지도를 불러올 수 없습니다.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.md),
          ElevatedButton(
            onPressed: _loadPlaces,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticMapCard() {
    final url = _staticMapUrl;
    final selected = _selectedPlace;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusLg),
              topRight: Radius.circular(AppSizes.radiusLg),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: url == null
                  ? Container(
                      color: AppColors.borderLight,
                      child: const Center(child: Text('지도 정보를 불러오는 중입니다.')),
                    )
                  : Image.network(
                      url,
                      key: ValueKey(url),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.borderLight,
                        child: const Center(child: Text('지도를 표시할 수 없습니다.')),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected?.name ?? '가까운 폐의약품 수거처',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  selected?.address ?? '목록에서 위치를 선택하면 상세 위치를 확인할 수 있습니다.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceTile(_PlaceView place) {
    final bool isSelected = place.id == _selectedPlaceId;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPlaceId = place.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusRound),
              ),
              child: const Icon(Icons.place, color: AppColors.primary),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '${place.type} · ${place.address}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    '${(place.distanceMeters / 1000).toStringAsFixed(2)} km',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.directions, color: AppColors.primary),
              onPressed: () => _showRouteDialog(context, place),
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteDialog(BuildContext context, _PlaceView place) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${place.name} 길 안내'),
          content: const Text('카카오맵에서 길 안내를 시작할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (_pos == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('위치 정보를 가져올 수 없습니다.'),
                      backgroundColor: Colors.red,
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
                  await launchUrl(webUri, mode: LaunchMode.externalApplication);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class _PickupRequestTab extends StatefulWidget {
  const _PickupRequestTab();

  @override
  State<_PickupRequestTab> createState() => _PickupRequestTabState();
}

class _PickupRequestTabState extends State<_PickupRequestTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedTime = '오전';
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
          Text(
            '방문 수거 신청',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // 신청자 정보
          _buildEditableInputField('연락처', _phoneController, '연락처를 입력하세요'),
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
                padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                splashFactory: NoSplash.splashFactory,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
              child: Text(
                '수거 신청하기',
                style: AppTextStyles.h6.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
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
            fillColor: AppColors.borderLight,
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
            contentPadding: const EdgeInsets.all(AppSizes.md),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '수거 희망일',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
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
        Text(
          '수거 희망 시간',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Row(
          children: [
            // 오전/오후 선택
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTime = _selectedTime == '오전' ? '오후' : '오전';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        _selectedTime,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            // 시간 선택
            Expanded(
              child: GestureDetector(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        _selectedTimeOfDay != null
                            ? '${_selectedTimeOfDay!.hour.toString().padLeft(2, '0')}:${_selectedTimeOfDay!.minute.toString().padLeft(2, '0')}'
                            : '시간 선택',
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
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTimeOfDay = picked;
      });
    }
  }

  void _submitRequest() {
    if (_phoneController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 필드를 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('수거 신청이 완료되었습니다'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
