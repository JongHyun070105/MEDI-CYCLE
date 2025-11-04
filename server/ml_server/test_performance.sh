#!/bin/bash

# ML 서버 성능 테스트 스크립트
BASE_URL="http://localhost:8000"

echo "🚀 ML 서버 성능 테스트 시작"
echo "================================"

# 1. 사용자 등록 테스트
echo ""
echo "📝 1. 사용자 등록 테스트"
echo "--------------------------------"
for i in {1..5}; do
  USER_ID="test_user_$i"
  echo "사용자 등록: $USER_ID"
  curl -s -X POST "$BASE_URL/api/users/$USER_ID/register" \
    -H "Content-Type: application/json" \
    -d "{
      \"user_id\": \"$USER_ID\",
      \"name\": \"테스트 사용자 $i\",
      \"age\": $((20 + i * 5)),
      \"medications\": [\"고혈압약\", \"당뇨약\", \"진통제\"],
      \"allergies\": [\"페니실린\"]
    }" | jq -r '.message // .status'
  sleep 0.5
done

# 2. 피드백 전송 테스트 (각 사용자마다 10개씩)
echo ""
echo "📊 2. 피드백 전송 테스트 (각 사용자당 10개)"
echo "--------------------------------"
for i in {1..5}; do
  USER_ID="test_user_$i"
  echo "사용자 $USER_ID 피드백 전송 중..."
  
  for j in {1..10}; do
    # 랜덤한 복용 여부 (70% 확률로 복용)
    TAKEN=$((RANDOM % 10 < 7 ? 1 : 0))
    
    # 실제 복용 시간 (07:00 ~ 22:00 사이)
    HOUR=$((7 + RANDOM % 16))
    MINUTE=$((RANDOM % 60))
    ACTUAL_TIME=$(printf "%02d:%02d" $HOUR $MINUTE)
    
    # 식사 시간 (분 단위)
    MEAL_TIME=$((420 + RANDOM % 960))  # 07:00 ~ 23:00
    
    # 약물 복용 시간 (식사 시간 + 0~60분)
    MEDICATION_TIME=$((MEAL_TIME + RANDOM % 60))
    
    # 만족도 (1-5)
    SATISFACTION=$((1 + RANDOM % 5))
    
    # 시간 정확도 (1-5)
    TIME_ACCURACY=$((1 + RANDOM % 5))
    
    if [ $TAKEN -eq 1 ]; then
      curl -s -X POST "$BASE_URL/api/users/$USER_ID/feedback" \
        -H "Content-Type: application/json" \
        -d "{
          \"taken\": true,
          \"actual_time\": \"$ACTUAL_TIME\",
          \"meal_time\": $MEAL_TIME,
          \"medication_time\": $MEDICATION_TIME,
          \"feedback_score\": $SATISFACTION,
          \"satisfaction\": $SATISFACTION,
          \"time_accuracy\": $TIME_ACCURACY
        }" > /dev/null
    else
      curl -s -X POST "$BASE_URL/api/users/$USER_ID/feedback" \
        -H "Content-Type: application/json" \
        -d "{
          \"taken\": false
        }" > /dev/null
    fi
    
    if [ $((j % 5)) -eq 0 ]; then
      echo "  피드백 $j/10 전송 완료"
    fi
  done
  echo "✅ 사용자 $USER_ID 피드백 전송 완료 (10개)"
done

# 3. 스케줄 조회 테스트
echo ""
echo "🔮 3. 개인화된 스케줄 조회 테스트"
echo "--------------------------------"
for i in {1..5}; do
  USER_ID="test_user_$i"
  echo "사용자 $USER_ID 스케줄 조회:"
  curl -s -X POST "$BASE_URL/api/users/$USER_ID/schedule" \
    -H "Content-Type: application/json" \
    -d "{\"medication_type\": \"고혈압약\"}" | jq -r '.prediction | "  학습 단계: \(.learning_stage), 신뢰도: \(.confidence), 방법: \(.method)"'
  sleep 0.3
done

# 4. 사용자 상태 조회 테스트
echo ""
echo "📈 4. 사용자 상태 조회 테스트"
echo "--------------------------------"
for i in {1..5}; do
  USER_ID="test_user_$i"
  echo "사용자 $USER_ID 상태:"
  curl -s -X GET "$BASE_URL/api/users/$USER_ID/status" | jq -r '. | "  학습 단계: \(.learning_stage), 신뢰도: \(.model_confidence), 피드백 수: \(.feedback_count)"'
  sleep 0.3
done

echo ""
echo "✅ 성능 테스트 완료!"
echo "================================"

