import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Kakao Places parsing', () {
    test('parse minimal documents list', () {
      final String jsonBody = json.encode({
        'documents': [
          {
            'id': '123',
            'place_name': '테스트약국',
            'road_address_name': '서울시 마포구 테스트로 1',
            'address_name': '서울시 마포구 테스트동 1-1',
            'x': '126.12345',
            'y': '37.56789',
            'phone': '02-000-0000',
            'category_group_name': '약국',
          },
          {
            'id': '456',
            'place_name': '테스트병원',
            'address_name': '서울시 마포구 병원동 2-2',
            'x': '126.22345',
            'y': '37.66789',
            'category_group_name': '병원',
          },
        ],
      });

      final Map<String, dynamic> map = json.decode(jsonBody);
      final List docs = (map['documents'] ?? []) as List;

      final items = docs.map((e) {
        return {
          'id': (e['id'] ?? '').toString(),
          'name': (e['place_name'] ?? '').toString(),
          'address': (e['road_address_name'] ?? e['address_name'] ?? '')
              .toString(),
          'x': double.tryParse((e['x'] ?? '0').toString()) ?? 0,
          'y': double.tryParse((e['y'] ?? '0').toString()) ?? 0,
          'phone': (e['phone'] ?? '').toString(),
          'category': (e['category_group_name'] ?? '').toString(),
        };
      }).toList();

      expect(items.length, 2);
      expect(items[0]['id'], '123');
      expect(items[0]['name'], '테스트약국');
      expect(items[0]['address'], '서울시 마포구 테스트로 1');
      expect(items[0]['category'], '약국');
      expect(items[1]['name'], '테스트병원');
      expect(items[1]['address'], '서울시 마포구 병원동 2-2');
      expect(items[1]['category'], '병원');
    });
  });
}
