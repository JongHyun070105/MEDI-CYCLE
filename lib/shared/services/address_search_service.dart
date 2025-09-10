import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressSearchService {
  static const String _baseUrl =
      'https://business.juso.go.kr/addrlink/addrLinkApi.do';
  static const String _confmKey =
      'devU01TX0FVVEgyMDI1MDkxMDE3MzcxMTExNjE2ODI='; // 약드셔유 실제 승인키

  static Future<List<AddressResult>> searchAddress(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?confmKey=$_confmKey&currentPage=1&countPerPage=10&keyword=$query&resultType=json',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // API 응답 구조 확인
        if (data['results'] != null) {
          final results = data['results'];

          // 검색 결과가 있는 경우
          if (results['juso'] != null) {
            final jusoList = results['juso'] as List;
            return jusoList
                .map((item) => AddressResult.fromJson(item))
                .toList();
          }
          // 검색 결과가 없는 경우 (정상적인 응답)
          else if (results['common'] != null) {
            print('검색 결과가 없습니다: ${results['common']['totalCount']}');
            return [];
          }
        }

        // API 오류 응답 처리
        if (data['results'] == null && data['error'] != null) {
          print('API 오류: ${data['error']}');
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('주소 검색 오류: $e');
    }

    return [];
  }

  static Future<List<String>> getSuggestions(String query) async {
    if (query.length < 2) return [];

    final results = await searchAddress(query);
    return results.map((result) => result.roadAddr).toList();
  }
}

class AddressResult {
  final String roadAddr;
  final String jibunAddr;
  final String zipNo;
  final String admCd;
  final String rnMgtSn;
  final String bdMgtSn;
  final String detBdNmList;
  final String bdNm;
  final String bdKdcd;
  final String siNm;
  final String sggNm;
  final String emdNm;
  final String liNm;
  final String rn;
  final String udrtYn;
  final String buldMnnm;
  final String buldSlno;
  final String mtYn;
  final String lnbrMnnm;
  final String lnbrSlno;
  final String emdNo;
  final String hstryYn;
  final String relJibun;
  final String hemdNm;

  AddressResult({
    required this.roadAddr,
    required this.jibunAddr,
    required this.zipNo,
    required this.admCd,
    required this.rnMgtSn,
    required this.bdMgtSn,
    required this.detBdNmList,
    required this.bdNm,
    required this.bdKdcd,
    required this.siNm,
    required this.sggNm,
    required this.emdNm,
    required this.liNm,
    required this.rn,
    required this.udrtYn,
    required this.buldMnnm,
    required this.buldSlno,
    required this.mtYn,
    required this.lnbrMnnm,
    required this.lnbrSlno,
    required this.emdNo,
    required this.hstryYn,
    required this.relJibun,
    required this.hemdNm,
  });

  factory AddressResult.fromJson(Map<String, dynamic> json) {
    return AddressResult(
      roadAddr: json['roadAddr'] ?? '',
      jibunAddr: json['jibunAddr'] ?? '',
      zipNo: json['zipNo'] ?? '',
      admCd: json['admCd'] ?? '',
      rnMgtSn: json['rnMgtSn'] ?? '',
      bdMgtSn: json['bdMgtSn'] ?? '',
      detBdNmList: json['detBdNmList'] ?? '',
      bdNm: json['bdNm'] ?? '',
      bdKdcd: json['bdKdcd'] ?? '',
      siNm: json['siNm'] ?? '',
      sggNm: json['sggNm'] ?? '',
      emdNm: json['emdNm'] ?? '',
      liNm: json['liNm'] ?? '',
      rn: json['rn'] ?? '',
      udrtYn: json['udrtYn'] ?? '',
      buldMnnm: json['buldMnnm'] ?? '',
      buldSlno: json['buldSlno'] ?? '',
      mtYn: json['mtYn'] ?? '',
      lnbrMnnm: json['lnbrMnnm'] ?? '',
      lnbrSlno: json['lnbrSlno'] ?? '',
      emdNo: json['emdNo'] ?? '',
      hstryYn: json['hstryYn'] ?? '',
      relJibun: json['relJibun'] ?? '',
      hemdNm: json['hemdNm'] ?? '',
    );
  }
}
