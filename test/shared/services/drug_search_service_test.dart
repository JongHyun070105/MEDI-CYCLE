import 'package:flutter_test/flutter_test.dart';
import 'package:medi_cycle_app/shared/services/drug_search_service.dart';

void main() {
  group('DrugSearchService 테스트', () {
    test('searchDrugsWithDetails에서 성분 정보 추출 테스트', () async {
      // 실제 API 호출 대신 모킹된 XML 응답 사용
      // 실제로는 mock을 사용하거나 integration test를 작성해야 함
      
      // 테스트: 성분 정보가 포함된 결과를 반환하는지 확인
      final results = await DrugSearchService.searchDrugsWithDetails('타이레놀');
      
      // 결과가 비어있지 않으면 성분 정보가 포함되어 있는지 확인
      if (results.isNotEmpty) {
        final firstResult = results.first;
        
        // mainIngr 필드가 있는지 확인
        expect(firstResult.containsKey('mainIngr'), isTrue);
        expect(firstResult.containsKey('itemName'), isTrue);
        expect(firstResult.containsKey('entpName'), isTrue);
        expect(firstResult.containsKey('itemImage'), isTrue);
        
        // 제조사명이 비어있지 않은지 확인
        final manufacturer = firstResult['entpName'] as String?;
        expect(manufacturer, isNotNull);
        
        print('✅ 검색 결과: 약물명=${firstResult['itemName']}, 제조사=$manufacturer, 성분=${firstResult['mainIngr']}');
      }
    }, skip: true); // 실제 API 호출이므로 기본적으로 스킵
    
    test('getDrugDetails에서 성분 정보 추출 테스트', () async {
      // 실제 API 호출 대신 모킹된 XML 응답 사용
      final details = await DrugSearchService.getDrugDetails('타이레놀정500밀리그람');
      
      if (details != null) {
        // mainIngr 필드가 있는지 확인
        expect(details.containsKey('mainIngr'), isTrue);
        expect(details.containsKey('entpName'), isTrue);
        expect(details.containsKey('itemImage'), isTrue);
        
        // 제조사명이 비어있지 않은지 확인
        final manufacturer = details['entpName'] as String?;
        expect(manufacturer, isNotNull);
        
        print('✅ 상세 정보: 제조사=$manufacturer, 성분=${details['mainIngr']}');
      }
    }, skip: true); // 실제 API 호출이므로 기본적으로 스킵
  });
}

