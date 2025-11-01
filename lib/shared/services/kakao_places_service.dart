import 'dart:convert';
import 'package:http/http.dart' as http;

class KakaoPlace {
  final String id;
  final String name;
  final String address;
  final double x; // longitude
  final double y; // latitude
  final String? phone;
  final String? category;

  KakaoPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.x,
    required this.y,
    this.phone,
    this.category,
  });
}

class KakaoPlacesService {
  static const String _workerBase =
      'https://take-your-medicine-api-proxy-production.how-about-this-api.workers.dev';

  static Future<List<KakaoPlace>> searchPlaces({
    required String query,
    required double x,
    required double y,
    int radius = 3000,
    int size = 15,
  }) async {
    final uri = Uri.parse('$_workerBase/kakao/places').replace(
      queryParameters: {
        'query': query,
        'x': x.toString(),
        'y': y.toString(),
        'radius': radius.toString(),
        'size': size.toString(),
      },
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];
    final Map<String, dynamic> jsonMap = json.decode(resp.body);
    final List docs = (jsonMap['documents'] ?? []) as List;
    return docs.map((e) {
      return KakaoPlace(
        id: (e['id'] ?? '').toString(),
        name: (e['place_name'] ?? '').toString(),
        address: (e['road_address_name'] ?? e['address_name'] ?? '').toString(),
        x: double.tryParse((e['x'] ?? '0').toString()) ?? 0,
        y: double.tryParse((e['y'] ?? '0').toString()) ?? 0,
        phone: (e['phone'] ?? '').toString(),
        category: (e['category_group_name'] ?? '').toString(),
      );
    }).toList();
  }

  static String buildStaticMapUrl({
    required double lat,
    required double lng,
    List<String> markers = const [],
    int level = 4,
    int width = 640,
    int height = 360,
  }) {
    final baseUri = Uri.parse('$_workerBase/kakao/static-map').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'level': level.toString(),
        'w': width.toString(),
        'h': height.toString(),
      },
    );

    if (markers.isEmpty) {
      return baseUri.toString();
    }

    final markerQuery = markers
        .map((m) => 'markers=${Uri.encodeComponent(m)}')
        .join('&');
    return '${baseUri.toString()}&$markerQuery';
  }
}
