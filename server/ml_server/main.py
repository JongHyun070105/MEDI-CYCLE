#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Federated Learning 기반 약물 알림 개인화 모델 서버
FastAPI를 사용한 REST API 서버
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, List, Optional
from datetime import datetime
import sys
import os

# 모델 파일 경로 추가
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from federated_medication_model import PersonalizedMedicationSystem

app = FastAPI(
    title="MediCycle ML Server",
    description="Federated Learning 기반 약물 알림 개인화 모델 서버",
    version="1.0.0"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 전역 모델 인스턴스
medication_system = PersonalizedMedicationSystem()

# Pydantic 모델 정의
class UserData(BaseModel):
    user_id: str
    name: str
    age: int
    medications: List[str]
    allergies: List[str] = []

class FeedbackData(BaseModel):
    taken: bool
    actual_time: Optional[str] = None  # HH:MM 형식
    meal_time: Optional[int] = None  # 분 단위
    medication_time: Optional[int] = None  # 분 단위
    feedback_score: Optional[int] = None
    satisfaction: Optional[int] = None
    time_accuracy: Optional[int] = None
    timestamp: Optional[str] = None

class ScheduleRequest(BaseModel):
    medication_type: str

# Health check
@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "ml_server"}

# 사용자 등록
@app.post("/api/users/{user_id}/register")
async def register_user(user_id: str, user_data: UserData):
    """사용자 등록 및 모델 초기화"""
    try:
        print(f"👤 사용자 등록 요청: user_id={user_id}, name={user_data.name}, age={user_data.age}, medications={user_data.medications}")
        
        if user_data.user_id != user_id:
            print(f"❌ user_id 불일치: {user_data.user_id} != {user_id}")
            raise HTTPException(status_code=400, detail="user_id 불일치")
        
        # 이미 등록된 사용자인지 확인
        is_new_user = user_id not in medication_system.user_data
        if is_new_user:
            print(f"✅ 새 사용자 등록: {user_id}")
        else:
            print(f"🔄 기존 사용자 정보 업데이트: {user_id}")
        
        medication_system.add_user(user_id, {
            "name": user_data.name,
            "age": user_data.age,
            "medications": user_data.medications,
            "allergies": user_data.allergies
        })
        
        # 등록 후 상태 확인
        user_info = medication_system.user_data.get(user_id)
        if user_info:
            print(f"✅ 사용자 등록 완료: user_id={user_id}, learning_stage={user_info.get('learning_stage', 'N/A')}, confidence={user_info.get('model_confidence', 'N/A')}")
        else:
            print(f"⚠️ 사용자 등록 후 정보를 찾을 수 없음: {user_id}")
        
        return {
            "status": "success",
            "message": f"사용자 {user_id} 등록 완료",
            "user_id": user_id
        }
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ 사용자 등록 실패: user_id={user_id}, error={str(e)}")
        raise HTTPException(status_code=500, detail=f"사용자 등록 실패: {str(e)}")

# 피드백 수신 및 학습
@app.post("/api/users/{user_id}/feedback")
async def receive_feedback(user_id: str, feedback: FeedbackData):
    """사용자 피드백 수신 및 모델 학습"""
    try:
        print(f"📥 피드백 수신: user_id={user_id}, taken={feedback.taken}, actual_time={feedback.actual_time}, satisfaction={feedback.satisfaction}")
        
        if user_id not in medication_system.user_data:
            print(f"❌ 사용자를 찾을 수 없음: {user_id}")
            raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다")
        
        # 피드백 데이터 변환
        feedback_dict = {
            "taken": feedback.taken,
            "actual_time": feedback.actual_time,
            "meal_time": feedback.meal_time or 450,  # 기본값
            "medication_time": feedback.medication_time or 480,  # 기본값
            "timestamp": feedback.timestamp or datetime.now().isoformat()
        }
        
        if feedback.feedback_score:
            feedback_dict["feedback_score"] = feedback.feedback_score
        if feedback.satisfaction:
            feedback_dict["satisfaction"] = feedback.satisfaction
        if feedback.time_accuracy:
            feedback_dict["time_accuracy"] = feedback.time_accuracy
        
        # 피드백 히스토리 개수 확인
        before_count = len(medication_system.feedback_history.get(user_id, []))
        
        # 모델 학습
        medication_system.receive_feedback(user_id, feedback_dict)
        
        # 학습 후 상태 확인
        after_count = len(medication_system.feedback_history.get(user_id, []))
        user_info = medication_system.user_data.get(user_id)
        
        print(f"✅ 피드백 처리 완료: user_id={user_id}, 피드백 수={before_count} -> {after_count}, learning_stage={user_info.get('learning_stage', 'N/A') if user_info else 'N/A'}, confidence={user_info.get('model_confidence', 'N/A') if user_info else 'N/A'}")
        
        return {
            "status": "success",
            "message": "피드백 처리 완료",
            "user_id": user_id
        }
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ 피드백 처리 실패: user_id={user_id}, error={str(e)}")
        raise HTTPException(status_code=500, detail=f"피드백 처리 실패: {str(e)}")

# 개인화된 알림 스케줄 조회
@app.post("/api/users/{user_id}/schedule")
async def get_personalized_schedule(user_id: str, request: ScheduleRequest):
    """개인화된 알림 스케줄 조회"""
    try:
        print(f"📅 스케줄 조회 요청: user_id={user_id}, medication_type={request.medication_type}")
        
        if user_id not in medication_system.user_data:
            print(f"❌ 사용자를 찾을 수 없음: {user_id}")
            raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다")
        
        user_info = medication_system.user_data.get(user_id)
        feedback_count = len(medication_system.feedback_history.get(user_id, []))
        print(f"📊 사용자 상태: learning_stage={user_info.get('learning_stage', 'N/A') if user_info else 'N/A'}, confidence={user_info.get('model_confidence', 'N/A') if user_info else 'N/A'}, feedback_count={feedback_count}")
        
        prediction = medication_system.predict_optimal_alert_time(
            user_id,
            request.medication_type
        )
        
        print(f"✅ 스케줄 예측 완료: user_id={user_id}, prediction={prediction}")
        
        return {
            "status": "success",
            "user_id": user_id,
            "medication_type": request.medication_type,
            "prediction": prediction
        }
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ 스케줄 조회 실패: user_id={user_id}, error={str(e)}")
        raise HTTPException(status_code=500, detail=f"스케줄 조회 실패: {str(e)}")

# 사용자 상태 조회
@app.get("/api/users/{user_id}/status")
async def get_user_status(user_id: str):
    """사용자 학습 상태 조회"""
    try:
        print(f"📊 상태 조회 요청: user_id={user_id}")
        
        if user_id not in medication_system.user_data:
            print(f"❌ 사용자를 찾을 수 없음: {user_id}")
            raise HTTPException(status_code=404, detail="사용자를 찾을 수 없습니다")
        
        user_info = medication_system.user_data[user_id]
        feedback_count = len(medication_system.feedback_history.get(user_id, []))
        
        print(f"✅ 상태 조회 완료: user_id={user_id}, learning_stage={user_info.get('learning_stage', 'N/A')}, confidence={user_info.get('model_confidence', 'N/A')}, feedback_count={feedback_count}")
        
        return {
            "status": "success",
            "user_id": user_id,
            "learning_stage": user_info["learning_stage"],
            "model_confidence": user_info["model_confidence"],
            "feedback_count": feedback_count
        }
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ 상태 조회 실패: user_id={user_id}, error={str(e)}")
        raise HTTPException(status_code=500, detail=f"상태 조회 실패: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

