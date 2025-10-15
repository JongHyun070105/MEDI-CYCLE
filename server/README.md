# MediCycle FastAPI Server

## 프로젝트 개요

MediCycle은 복약 관리 및 AI 챗봇 기능을 제공하는 FastAPI 기반 서버입니다.

### 주요 기능

- 사용자 인증 (회원가입/로그인/JWT)
- 복약 정보 관리 (약 이름, 복용 시간, 횟수, 기간 등)
- 약상자 상태 관리 (감지, 배터리, 잠금)
- AI 챗봇 (Gemini API + 공공데이터포털 e약은요 연동)

## 시스템 요구사항

### 필수 요구사항

- **Python**: 3.11 이상
- **MySQL**: 8.0 이상
- **Git**: 코드 다운로드용

### 선택 요구사항

- **Gemini API Key**: AI 챗봇 기능 사용 시
- **공공데이터포털 계정**: e약은요 API 사용 시

## 설치 및 설정

### 1단계: 저장소 클론 및 이동

```bash
git clone <repository-url>
cd server
```

### 2단계: Python 가상환경 생성 및 활성화

#### Windows (PowerShell/CMD)

```bash
python -m venv .venv
.venv\Scripts\activate
```

#### macOS/Linux

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3단계: 의존성 설치

```bash
pip install -r requirements.txt
```

## 환경 변수 설정

### `.env` 파일 생성

프로젝트 루트(`server/`)에 `.env` 파일을 생성하고 다음 내용을 입력하세요:

```env
# MySQL 데이터베이스 설정
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=your_mysql_password
MYSQL_DB=medicycle

# JWT 토큰 설정
JWT_SECRET=75009c0cf700fae4116f7f93d165944e
JWT_ALG=HS256
JWT_EXPIRES_MIN=60

# Gemini AI API (선택사항)
GEMINI_API_KEY=your_gemini_api_key_here

# 공공데이터포털 e약은요 API (선택사항)
MFDS_SERVICE_KEY=your_mfds_service_key_here
```

### 환경 변수 설명

- `MYSQL_*`: MySQL 데이터베이스 연결 정보
- `JWT_SECRET`: JWT 토큰 서명용 비밀키 (강력한 랜덤 문자열 권장)
- `GEMINI_API_KEY`: Google Gemini AI API 키 ([여기서 발급](https://makersuite.google.com/app/apikey))
- `MFDS_SERVICE_KEY`: 식품의약품안전처 공공데이터포털 서비스키 ([여기서 발급](https://www.data.go.kr/data/15075057/openapi.do))

## 데이터베이스 설정

### 1단계: MySQL 데이터베이스 생성

```sql
CREATE DATABASE IF NOT EXISTS medicycle CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2단계: 테이블 생성

프로젝트의 `sql/schema.sql` 파일을 실행하거나, 아래 SQL을 직접 실행하세요:

```bash
# 방법 1: SQL 파일 실행
mysql -u root -p medicycle < sql/schema.sql

# 방법 2: MySQL 클라이언트에서 직접 실행
mysql -u root -p
USE medicycle;
# sql/schema.sql 내용 복사하여 실행
```

### 3단계: 데이터베이스 연결 확인

서버 실행 후 로그에서 연결 상태를 확인하세요.

## 서버 실행

### 개발 모드 (권장)

```bash
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

### 프로덕션 모드

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 서버 확인

브라우저에서 `http://127.0.0.1:8000/health` 접속 시 `{"status": "ok"}` 응답 확인

## API 문서 및 테스트

### Swagger UI

- URL: `http://127.0.0.1:8000/docs`
- 인터랙티브 API 문서 및 테스트 가능

### 주요 엔드포인트

#### 인증

- `POST /auth/signup`: 회원가입
- `POST /auth/login`: 로그인
- `GET /auth/me`: 내 정보 조회

#### 복약 관리

- `GET /medications/`: 복약 목록 조회
- `POST /medications/`: 복약 등록
- `GET /medications/{id}`: 복약 상세 조회
- `PUT /medications/{id}`: 복약 수정
- `DELETE /medications/{id}`: 복약 삭제

#### 약상자 관리

- `GET /pillbox/status`: 약상자 상태 조회
- `POST /pillbox/status`: 약상자 상태 설정

#### AI 기능

- `POST /ai/chat`: AI 챗봇 (일반 대화)
- `POST /ai/feedback`: AI 피드백 (의약품 정보)

### 인증 방식

보호된 엔드포인트 사용 시 HTTP 헤더에 JWT 토큰을 포함해야 합니다:

```
Authorization: Bearer <your_jwt_token>
```

## 테스트 방법

### 1. 회원가입 테스트

```bash
curl -X POST http://127.0.0.1:8000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "테스트 사용자",
    "age": 30
  }'
```

### 2. 로그인 테스트

```bash
curl -X POST http://127.0.0.1:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 3. AI 챗봇 테스트 (토큰 필요)

```bash
curl -X POST http://127.0.0.1:8000/ai/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_jwt_token>" \
  -d '{
    "message": "타이레놀 부작용 알려줘"
  }'
```

## 문제 해결

### 일반적인 오류

#### 1. 데이터베이스 연결 오류

- **증상**: `OperationalError: (1049, "Unknown database 'medicycle'")`
- **해결**: MySQL에서 데이터베이스 생성 확인
- **확인**: `.env`의 DB 설정 값 확인

#### 2. 모듈 없음 오류

- **증상**: `ModuleNotFoundError: No module named 'xxx'`
- **해결**: 가상환경 활성화 후 `pip install -r requirements.txt` 재실행

#### 3. JWT 토큰 오류

- **증상**: `401 Unauthorized` 또는 `403 Forbidden`
- **해결**: 로그인 후 받은 토큰을 `Authorization: Bearer <token>` 헤더에 포함

#### 4. Gemini API 오류

- **증상**: AI 기능에서 오류 발생
- **해결**: `.env`의 `GEMINI_API_KEY` 확인 및 API 키 유효성 검증

### 로그 확인

서버 실행 시 콘솔에서 상세한 로그를 확인할 수 있습니다. 오류 발생 시 로그 내용을 확인하세요.

## 개발 환경 설정

### 코드 스타일

- Python 코드는 PEP 8 스타일 가이드 준수
- FastAPI의 자동 문서화 기능 활용

### 디버깅

- `--reload` 옵션으로 코드 변경 시 자동 재시작
- Swagger UI에서 API 테스트 및 디버깅 가능

## 배포 가이드

### Docker 사용 (선택사항)

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 환경 변수 관리

- 프로덕션 환경에서는 환경 변수를 안전하게 관리하세요
- JWT_SECRET은 강력한 랜덤 문자열을 사용하세요

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 지원

문제가 발생하면 GitHub Issues를 통해 문의해 주세요.
