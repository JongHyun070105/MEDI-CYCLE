# 메디사이클 (MediCycle)

## 실행 요약

- 서버: `cd server && docker-compose up -d --build`
- 앱: `flutter run --dart-define=KAKAO_APP_KEY=YOUR_KAKAO_JS_KEY`
- 통합 테스트: `flutter test test/features/integration/full_flow_test.dart -r expanded`

## 현재 백엔드

- 메인: Node.js/Express (`server/src/`)
- 레거시: FastAPI (`server/app/`) – 데모/참고용. 배포/실행 대상 아님

## 📱 프로젝트 개요

**메디사이클**은 안전한 의약품 순환 관리 서비스로, 가정에서 복용하지 않고 남거나 유효기간이 지나 부적절하게 폐기된 의약품으로 인한 수질 및 토양 오염을 방지하는 통합 플랫폼입니다.

## 🌍 환경 문제 해결

### 문제 정의

- **의약품 오염**: 항생제, 소염진통제, 호르몬제 등이 하수처리 시설에서 완벽히 제거되지 않아 강과 바다로 유입
- **생태계 영향**: 수중 생물의 생식 기능 교란, 항생제 내성 확산, '슈퍼 박테리아' 발생 위험
- **연구 근거**: _Frontiers in Environmental Science_ (2022) 논문 "Minimizing the environmental impact of unused pharmaceuticals: Review focused on prevention"

### 해결 방안

- **통합 관리**: 의약품 구매부터 복용, 폐기까지 전 과정 관리
- **스마트 알림**: 복용 알림 및 폐의약품 수거 알림
- **사회적 지원**: 거동이 불편한 노인, 만성질환자 등 취약 계층을 위한 찾아가는 서비스

## 🚀 주요 기능

### 1. 스마트 약물 관리

- **QR 코드 스캔**: 처방전 QR코드로 자동 약물 등록
- **복용 알림**: 정해진 시간에 복용 알림
- **복용 기록**: 복용 이력 및 통계 관리
- **약물 캘린더**: 복용 일정 시각화

### 2. 폐의약품 관리

- **폐기 알림**: 유효기간 임박 시 자동 알림
- **수거함 찾기**: GPS 기반 근처 폐의약품 수거함 안내
- **찾아가는 서비스**: 거동 불편자를 위한 방문 수거 예약

### 3. 약국 연계

- **B2B 솔루션**: 참여 약국용 재고 관리 시스템
- **수거 내역 관리**: 폐의약품 처리 업체와의 연계 지원

## 🏗️ 기술 아키텍처

### Frontend

- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **Clean Architecture**: 도메인, 데이터, 프레젠테이션 레이어 분리
- **Riverpod**: 상태 관리 및 의존성 주입
- **AutoRoute**: 라우팅 관리

### Backend (계획)

- **Node.js/Express**: RESTful API 서버
- **PostgreSQL**: 메인 데이터베이스
- **Redis**: 캐싱 및 세션 관리
- **Firebase**: 푸시 알림 및 실시간 데이터

### IoT 연동 (계획)

- **라즈베리파이**: 스마트 수거함 제어 및 모니터링
- **센서**: 용량, 온도, 잠금 상태 감지
- **Wi-Fi/LTE**: 실시간 데이터 전송

## 📁 프로젝트 구조

```
lib/
├── core/                    # 핵심 기능
│   ├── constants/          # 앱 상수 (색상, 텍스트 스타일, 크기)
│   ├── theme/              # 앱 테마 설정
│   ├── errors/             # 에러 처리
│   ├── network/            # 네트워크 관련
│   └── utils/              # 유틸리티 함수
├── features/               # 기능별 모듈
│   ├── auth/               # 인증
│   ├── medication/         # 약물 관리
│   ├── disposal/           # 폐의약품 관리
│   ├── pharmacy/           # 약국 연계
│   └── profile/            # 사용자 프로필
├── shared/                 # 공통 모듈
│   ├── models/             # 공통 모델
│   ├── widgets/            # 재사용 위젯
│   └── services/           # 공통 서비스
└── main.dart               # 앱 진입점
```

## 🛠️ 개발 환경 설정

### 필수 요구사항

- Flutter SDK 3.8.1 이상
- Dart SDK 3.8.1 이상
- Android Studio / VS Code
- iOS 개발을 위한 Xcode (macOS)

### 설치 및 실행

1. **저장소 클론**

```bash
git clone https://github.com/your-username/medi_cycle_app.git
cd medi_cycle_app
```

2. **의존성 설치**

```bash
flutter pub get
```

3. **코드 생성** (Freezed, Riverpod 등)

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **앱 실행**

```bash
flutter run
```

### 개발 도구

- **코드 생성**: `flutter packages pub run build_runner watch`
- **코드 분석**: `flutter analyze`
- **테스트 실행**: `flutter test`
- **빌드**: `flutter build apk` (Android) / `flutter build ios` (iOS)

## 🎨 UI/UX 디자인

### 디자인 시스템

- **Material Design 3**: 최신 Material Design 가이드라인 준수
- **반응형 디자인**: 다양한 화면 크기 지원
- **접근성**: 색맹, 시각 장애인을 위한 고대비 및 음성 안내

### 색상 테마

- **Primary**: 환경 친화적 녹색 (#4CAF50)
- **Secondary**: 신뢰감 있는 파란색 (#2196F3)
- **Accent**: 주의를 끄는 주황색 (#FF9800)
- **Eco Colors**: 환경 보호를 상징하는 색상들

## 📊 데이터 모델

### 핵심 엔티티

- **Medication**: 약물 정보 (이름, 용량, 복용법, 유효기간 등)
- **MedicationSchedule**: 복용 스케줄 (시간, 복용 여부, 기록)
- **DisposalRecord**: 폐의약품 기록 (종류, 수량, 처리 방법)
- **Pharmacy**: 약국 정보 (위치, 서비스, 연락처)

## 🔒 보안 및 개인정보

### 데이터 보호

- **암호화**: 민감한 의료 정보 AES-256 암호화
- **인증**: 생체 인증, PIN, 패턴 잠금 지원
- **권한 관리**: 최소 권한 원칙 적용
- **GDPR 준수**: 유럽 개인정보보호법 준수

### 개인정보 수집

- **필수**: 약물 정보, 복용 기록, 기본 프로필
- **선택**: 위치 정보 (근처 약국 찾기), 사용 통계
- **저장**: 로컬 저장소 우선, 클라우드 동기화 선택적

## 🧪 테스트

### 테스트 전략

- **Unit Tests**: 비즈니스 로직 단위 테스트
- **Widget Tests**: UI 컴포넌트 테스트
- **Integration Tests**: 전체 기능 통합 테스트
- **E2E Tests**: 사용자 시나리오 기반 테스트

### 테스트 실행

```bash
# 단위 테스트
flutter test

# 특정 테스트 파일
flutter test test/medication_test.dart

# 커버리지 포함
flutter test --coverage
```

## 📱 배포

### Android

- **Google Play Store**: 정식 배포
- **APK 다운로드**: 직접 설치 지원
- **AAB**: App Bundle 형식 지원

### iOS

- **App Store**: 정식 배포
- **TestFlight**: 베타 테스트
- **Enterprise**: 기업 내부 배포

## 🤝 기여하기

### 개발 가이드라인

- **코드 스타일**: Dart 공식 스타일 가이드 준수
- **커밋 메시지**: Conventional Commits 형식 사용
- **PR 템플릿**: 기능 설명, 테스트 결과, 스크린샷 포함

### 기여 프로세스

1. Fork 저장소
2. 기능 브랜치 생성 (`feature/medication-management`)
3. 코드 작성 및 테스트
4. Pull Request 생성
5. 코드 리뷰 및 병합

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 📞 연락처

- **프로젝트 관리자**: [이메일]
- **기술 문의**: [이메일]
- **버그 리포트**: [GitHub Issues](https://github.com/your-username/medi_cycle_app/issues)

## 🙏 감사의 말

- **환경 보호 연구자들**: 의약품 오염 문제 연구
- **의료진**: 의약품 안전 관리 가이드라인
- **오픈소스 커뮤니티**: Flutter, Dart 등 훌륭한 도구들
- **사용자들**: 환경 보호를 위한 참여와 피드백

---

**메디사이클**과 함께 지구를 더 건강하게 만들어가요! 🌱💊♻️
