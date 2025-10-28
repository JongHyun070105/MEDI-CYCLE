import 'package:flutter_test/flutter_test.dart';
import 'package:medi_cycle_app/shared/services/ocr_service.dart';

void main() {
  group('OcrService.extractCandidateDrugNames', () {
    test('returns plausible drug names from text lines', () async {
      const sample = '''
타이레놀 500mg
용법: 1일 3회
아스피린 정
기타문장
''';

      final result = await ocrService.extractCandidateDrugNames(sample);
      // 최소 한두 개 후보가 나와야 함
      expect(result.isNotEmpty, true);
      expect(result.any((e) => e.contains('타이')), true);
    });
  });
}
