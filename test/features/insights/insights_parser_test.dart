import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> buildInsightsSample() {
  return {
    'overallPct': 82,
    'message': '최근 3개월간 복약 성실도가 향상되었습니다.',
    'tips': ['취침 전 알람 설정', '주말 복약 루틴 점검'],
    'months': [
      {'month': '2025-08', 'adherence_pct': 78},
      {'month': '2025-09', 'pct': 81},
      {'month': '2025-10', 'adherence_pct': '85'},
    ],
  };
}

void main() {
  group('Insights parsing', () {
    test('accepts pct or adherence_pct and normalizes to int', () {
      final data = buildInsightsSample();
      final months = List<Map<String, dynamic>>.from(data['months'] ?? []);
      final parsed = months.map((m) {
        final dynamic raw = m['pct'] ?? m['adherence_pct'] ?? 0;
        final int pct = int.tryParse(raw.toString()) ?? 0;
        return {'month': m['month'], 'pct': pct};
      }).toList();

      expect(parsed.length, 3);
      expect(parsed[0]['month'], '2025-08');
      expect(parsed[0]['pct'], 78);
      expect(parsed[1]['pct'], 81);
      expect(parsed[2]['pct'], 85);
    });

    test('overallPct and tips existence', () {
      final data = buildInsightsSample();
      final int overall =
          int.tryParse((data['overallPct'] ?? 0).toString()) ?? 0;
      final List<String> tips = List<String>.from(data['tips'] ?? const []);

      expect(overall, 82);
      expect(tips, isNotEmpty);
    });
  });
}
