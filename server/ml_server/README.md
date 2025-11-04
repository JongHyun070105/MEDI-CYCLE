# ML Server - Federated Learning 기반 약물 알림 개인화 모델

## 개요

Federated Learning, Meta-Learning, Continual Learning을 활용한 개인화된 약물 알림 시간 예측 모델 서버입니다.

## 실행 방법

### 로컬 실행

```bash
cd ml_server
pip install -r requirements.txt
python main.py
```

또는 uvicorn 직접 실행:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Docker 실행

```bash
docker-compose up ml_server
```

## API 엔드포인트

### Health Check
- `GET /health` - 서버 상태 확인

### 사용자 등록
- `POST /api/users/{user_id}/register` - 사용자 등록 및 모델 초기화
  - Request Body:
    ```json
    {
      "user_id": "string",
      "name": "string",
      "age": 30,
      "medications": ["약물1", "약물2"],
      "allergies": ["알레르기1"]
    }
    ```

### 피드백 수신
- `POST /api/users/{user_id}/feedback` - 피드백 수신 및 모델 학습
  - Request Body:
    ```json
    {
      "taken": true,
      "actual_time": "08:30",
      "meal_time": 450,
      "medication_time": 480,
      "feedback_score": 5,
      "satisfaction": 4,
      "time_accuracy": 5
    }
    ```

### 개인화된 스케줄 조회
- `POST /api/users/{user_id}/schedule` - 개인화된 알림 스케줄 조회
  - Request Body:
    ```json
    {
      "medication_type": "고혈압약"
    }
    ```
  - Response:
    ```json
    {
      "status": "success",
      "user_id": "15",
      "medication_type": "고혈압약",
      "prediction": {
        "predicted_times": {
          "breakfast": "07:30",
          "lunch": "12:00",
          "dinner": "18:30"
        },
        "confidence": 0.75,
        "method": "meta_learning",
        "learning_stage": 2
      }
    }
    ```

### 사용자 상태 조회
- `GET /api/users/{user_id}/status` - 사용자 학습 상태 조회

## 모델 구조

- **Federated Learning**: 개인정보 보호를 위한 로컬 모델 학습
- **Meta-Learning**: 새로운 사용자에게 빠르게 적응
- **Continual Learning**: 지속적인 학습으로 시간 경과에 따른 패턴 변화 대응
- **Online Learning**: 실시간 피드백 기반 모델 업데이트

## 학습 단계

1. **1단계 (초기)**: 기본 패턴 사용 (신뢰도: 0.6)
2. **2단계 (학습 중)**: Meta-Learning 적용 (피드백 5개 이상, 신뢰도: 0.75)
3. **3단계 (개인화 완료)**: 완전 개인화된 모델 (피드백 10개 이상, 신뢰도: 0.8+)

