import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class DrugSearchService {
  // Use Cloudflare Worker proxy to protect API keys
  static const String _workerBaseUrl =
      'https://take-your-medicine-api-proxy-production.how-about-this-api.workers.dev';

  /// 의약품명으로 검색하여 자동완성 제안 목록을 반환 (약 이름만)
  static Future<List<String>> searchDrugNames(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }

    try {
      final results = await searchDrugsWithDetails(query);
      return results.map((r) => r['itemName'] as String).toList();
    } catch (e) {
      print('의약품 검색 중 예외 발생: $e');
      return _getLocalDrugSuggestions(query);
    }
  }

  /// 의약품명으로 검색하여 상세 정보 포함 목록 반환
  static Future<List<Map<String, dynamic>>> searchDrugsWithDetails(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }

    try {
      // Call Cloudflare Worker proxy (XML passthrough)
      final url =
          '$_workerBaseUrl/drug-search?itemName=${Uri.encodeComponent(query)}&pageNo=1&numOfRows=50';
      print('API 요청 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/xml; charset=utf-8',
          'Content-Type': 'application/xml; charset=utf-8',
        },
      );

      print('API 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        // 응답 본문을 UTF-8로 디코딩
        final responseBody = utf8.decode(response.bodyBytes);

        // XML 파싱
        final document = XmlDocument.parse(responseBody);
        final List<Map<String, dynamic>> results = [];

        // XML에서 item 정보 추출
        final items = document.findAllElements('item');
        print('API 응답에서 ${items.length}개의 아이템을 찾았습니다.');

        for (var item in items) {
          final itemNameElement = item.findElements('itemName').firstOrNull;
          final entpNameElement = item.findElements('entpName').firstOrNull;
          final itemImageElement = item.findElements('itemImage').firstOrNull;
          final mainIngrElement = item.findElements('mainIngr').firstOrNull;
          final mainItemIngrElement = item.findElements('mainItemIngr').firstOrNull;
          
          if (itemNameElement != null) {
            final itemName = itemNameElement.text.trim();
            if (itemName.isNotEmpty) {
              // 성분 정보 추출: mainIngr -> mainItemIngr -> 약 이름에서 괄호 안 추출
              String ingredient = '';
              
              // mainIngr에서 성분 추출 시도
              if (mainIngrElement != null) {
                final mainIngrText = mainIngrElement.text.trim();
                if (mainIngrText.isNotEmpty) {
                  ingredient = mainIngrText;
                }
              }
              
              // mainIngr가 비어있으면 mainItemIngr에서 추출 시도
              if (ingredient.isEmpty && mainItemIngrElement != null) {
                final mainItemIngrText = mainItemIngrElement.text.trim();
                if (mainItemIngrText.isNotEmpty) {
                  ingredient = mainItemIngrText;
                }
              }
              
              // 성분이 비어있으면 약 이름에서 괄호 안 추출 시도
              if (ingredient.isEmpty && itemName.isNotEmpty) {
                final match = RegExp(r'\(([^)]+)\)').firstMatch(itemName);
                if (match != null) {
                  ingredient = match.group(1) ?? '';
                }
              }
              
              results.add({
                'itemName': itemName,
                'entpName': entpNameElement?.text.trim() ?? '',
                'itemImage': itemImageElement?.text.trim() ?? '',
                'mainIngr': ingredient,
              });
              print('추가된 의약품: $itemName (제조사: ${entpNameElement?.text.trim() ?? '없음'}, 성분: ${ingredient.isNotEmpty ? ingredient : '없음'}, 이미지: ${itemImageElement?.text.trim() ?? '없음'})');
            }
          }
        }

        // API에서 결과가 있으면 반환, 없으면 빈 리스트
        if (results.isNotEmpty) {
          print('API에서 ${results.length}개의 의약품을 찾았습니다.');
          return results;
        } else {
          print('API에서 검색 결과가 없습니다.');
          return [];
        }
      } else {
        print('의약품 검색 API 오류: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('의약품 검색 중 예외 발생: $e');
      return [];
    }
  }

  /// 의약품 상세 정보 조회
  static Future<Map<String, dynamic>?> getDrugDetails(String drugName) async {
    try {
      final url =
          '$_workerBaseUrl/drug-detail?itemName=${Uri.encodeComponent(drugName)}';

      print('약 상세 정보 API 요청 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/xml; charset=utf-8',
          'Content-Type': 'application/xml; charset=utf-8',
        },
      );

      print('약 상세 정보 API 응답 상태 코드: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        print('약 상세 정보 API 응답 내용: $responseBody');

        // XML 파싱
        final document = XmlDocument.parse(responseBody);
        final items = document.findAllElements('item');

        print('약 상세 정보 API 응답에서 ${items.length}개의 아이템을 찾았습니다.');

        if (items.isNotEmpty) {
          final item = items.first;
          final mainIngrElement = item.findElements('mainIngr').firstOrNull;
          final mainItemIngrElement = item.findElements('mainItemIngr').firstOrNull;
          final itemName = item.findElements('itemName').firstOrNull?.text.trim() ?? '';
          
          // 성분 정보 추출: mainIngr -> mainItemIngr -> 약 이름에서 괄호 안 추출
          String ingredient = '';
          
          // mainIngr에서 성분 추출 시도
          if (mainIngrElement != null) {
            final mainIngrText = mainIngrElement.text.trim();
            if (mainIngrText.isNotEmpty) {
              ingredient = mainIngrText;
            }
          }
          
          // mainIngr가 비어있으면 mainItemIngr에서 추출 시도
          if (ingredient.isEmpty && mainItemIngrElement != null) {
            final mainItemIngrText = mainItemIngrElement.text.trim();
            if (mainItemIngrText.isNotEmpty) {
              ingredient = mainItemIngrText;
            }
          }
          
          // 성분이 비어있으면 약 이름에서 괄호 안 추출 시도
          if (ingredient.isEmpty && itemName.isNotEmpty) {
            final match = RegExp(r'\(([^)]+)\)').firstMatch(itemName);
            if (match != null) {
              ingredient = match.group(1) ?? '';
            }
          }
          
          return {
            'entpName':
                item.findElements('entpName').firstOrNull?.text.trim() ?? '',
            'itemName': itemName,
            'itemSeq':
                item.findElements('itemSeq').firstOrNull?.text.trim() ?? '',
            'mainIngr': ingredient,
            'efcyQesitm':
                item.findElements('efcyQesitm').firstOrNull?.text.trim() ?? '',
            'useMethodQesitm':
                item.findElements('useMethodQesitm').firstOrNull?.text.trim() ??
                '',
            'atpnWarnQesitm':
                item.findElements('atpnWarnQesitm').firstOrNull?.text.trim() ??
                '',
            'atpnQesitm':
                item.findElements('atpnQesitm').firstOrNull?.text.trim() ?? '',
            'intrcQesitm':
                item.findElements('intrcQesitm').firstOrNull?.text.trim() ?? '',
            'seQesitm':
                item.findElements('seQesitm').firstOrNull?.text.trim() ?? '',
            'depositMethodQesitm':
                item
                    .findElements('depositMethodQesitm')
                    .firstOrNull
                    ?.text
                    .trim() ??
                '',
            'itemImage':
                item.findElements('itemImage').firstOrNull?.text.trim() ?? '',
            'openDe':
                item.findElements('openDe').firstOrNull?.text.trim() ?? '',
            'updateDe':
                item.findElements('updateDe').firstOrNull?.text.trim() ?? '',
          };
        } else {
          print('약 상세 정보: 검색 결과가 없습니다.');
        }
      } else {
        print('약 상세 정보 API 오류: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('약 상세 정보 조회 중 예외 발생: $e');
    }
    return null;
  }

  /// 로컬 더미 데이터에서 검색어로 시작하는 의약품명 반환
  static List<String> _getLocalDrugSuggestions(String query) {
    const List<String> allDrugs = [
      '타이레놀',
      '타스민',
      '타리겐',
      '타리도핀',
      '타리젯',
      '타이리놀',
      '타스놀',
      '타세놀',
      '아스피린',
      '아세트아미노펜',
      '아목시실린',
      '아목시실린클라불란산',
      '이부프로펜',
      '이부펜',
      '이부겔',
      '이부프로펜겔',
      '메트포르민',
      '메트포르민염산염',
      '메트포르민정',
      '로시트로마이신',
      '로시트로마이신정',
      '로시트로마이신캡슐',
      '세파클러',
      '세파클러정',
      '세파클러캡슐',
      '세파클러시럽',
      '아목시실린',
      '아목시실린정',
      '아목시실린캡슐',
      '아목시실린시럽',
      '클라리트로마이신',
      '클라리트로마이신정',
      '클라리트로마이신캡슐',
      '시프로플록사신',
      '시프로플록사신정',
      '시프로플록사신캡슐',
      '레보플록사신',
      '레보플록사신정',
      '레보플록사신캡슐',
      '옥시코돈',
      '옥시코돈정',
      '옥시코돈캡슐',
      '모르핀',
      '모르핀정',
      '모르핀주사액',
      '펜타닐',
      '펜타닐패치',
      '펜타닐주사액',
      '디아제팜',
      '디아제팜정',
      '디아제팜캡슐',
      '로라제팜',
      '로라제팜정',
      '로라제팜캡슐',
      '알프라졸람',
      '알프라졸람정',
      '알프라졸람캡슐',
      '클로나제팜',
      '클로나제팜정',
      '클로나제팜캡슐',
      '프레드니솔론',
      '프레드니솔론정',
      '프레드니솔론캡슐',
      '덱사메타손',
      '덱사메타손정',
      '덱사메타손캡슐',
      '하이드로코르티손',
      '하이드로코르티손정',
      '하이드로코르티손크림',
      '베타메타손',
      '베타메타손정',
      '베타메타손크림',
      '트리암시놀론',
      '트리암시놀론정',
      '트리암시놀론크림',
      '부데소니드',
      '부데소니드정',
      '부데소니드흡입제',
      '플루티카손',
      '플루티카손정',
      '플루티카손흡입제',
      '몬테루카스트',
      '몬테루카스트정',
      '몬테루카스트캡슐',
      '로라타딘',
      '로라타딘정',
      '로라타딘캡슐',
      '세티리진',
      '세티리진정',
      '세티리진캡슐',
      '펙소페나딘',
      '펙소페나딘정',
      '펙소페나딘캡슐',
      '디펜히드라민',
      '디펜히드라민정',
      '디펜히드라민캡슐',
      '클로르페니라민',
      '클로르페니라민정',
      '클로르페니라민캡슐',
      '프로메타진',
      '프로메타진정',
      '프로메타진캡슐',
      '메토클로프라미드',
      '메토클로프라미드정',
      '메토클로프라미드캡슐',
      '돔페리돈',
      '돔페리돈정',
      '돔페리돈캡슐',
      '란소프라졸',
      '란소프라졸정',
      '란소프라졸캡슐',
      '오메프라졸',
      '오메프라졸정',
      '오메프라졸캡슐',
      '에소메프라졸',
      '에소메프라졸정',
      '에소메프라졸캡슐',
      '판토프라졸',
      '판토프라졸정',
      '판토프라졸캡슐',
      '라베프라졸',
      '라베프라졸정',
      '라베프라졸캡슐',
      '시메티딘',
      '시메티딘정',
      '시메티딘캡슐',
      '라니티딘',
      '라니티딘정',
      '라니티딘캡슐',
      '파모티딘',
      '파모티딘정',
      '파모티딘캡슐',
      '니자티딘',
      '니자티딘정',
      '니자티딘캡슐',
      '수크랄페이트',
      '수크랄페이트정',
      '수크랄페이트캡슐',
      '미소프로스톨',
      '미소프로스톨정',
      '미소프로스톨캡슐',
      '비스무트',
      '비스무트정',
      '비스무트캡슐',
      '메토트렉세이트',
      '메토트렉세이트정',
      '메토트렉세이트캡슐',
      '설파살라진',
      '설파살라진정',
      '설파살라진캡슐',
      '메살라진',
      '메살라진정',
      '메살라진캡슐',
      '인플릭시맙',
      '인플릭시맙주사액',
      '인플릭시맙주사기',
      '아달리무맙',
      '아달리무맙주사액',
      '아달리무맙주사기',
      '에타너셉트',
      '에타너셉트주사액',
      '에타너셉트주사기',
      '리툭시맙',
      '리툭시맙주사액',
      '리툭시맙주사기',
      '토실리주맙',
      '토실리주맙주사액',
      '토실리주맙주사기',
      '아바타셉트',
      '아바타셉트주사액',
      '아바타셉트주사기',
      '아나킨라',
      '아나킨라주사액',
      '아나킨라주사기',
      '토파시티니브',
      '토파시티니브정',
      '토파시티니브캡슐',
      '바리시티니브',
      '바리시티니브정',
      '바리시티니브캡슐',
      '아프레미라스트',
      '아프레미라스트정',
      '아프레미라스트캡슐',
      '아프레미라스트연질캡슐',
      '아프레미라스트경질캡슐',
    ];

    return allDrugs
        .where((drug) => drug.toLowerCase().startsWith(query.toLowerCase()))
        .take(10)
        .toList();
  }
}
