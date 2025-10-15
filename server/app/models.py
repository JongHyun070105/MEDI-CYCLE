from datetime import datetime, date, time
from sqlalchemy import Column, Integer, String, DateTime, Date, Time, Boolean, ForeignKey, Text
from sqlalchemy.orm import relationship

from .db import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    name = Column(String(100), nullable=True)
    age = Column(Integer, nullable=True)
    address = Column(String(255), nullable=True)
    gender = Column(String(20), nullable=True)  # male/female/other 등 자유 텍스트
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)

    medications = relationship("Medication", back_populates="user", cascade="all,delete")


class Medication(Base):
    __tablename__ = "medications"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)

    name = Column(String(255), nullable=False)
    daily_count = Column(Integer, nullable=False)  # 1 ~ 6

    # 복용 시간별 정보(최대 6회). 시간/식전후/분
    time1 = Column(Time, nullable=True)
    time1_meal = Column(String(10), nullable=True)  # after/before
    time1_offset_min = Column(Integer, nullable=True)

    time2 = Column(Time, nullable=True)
    time2_meal = Column(String(10), nullable=True)
    time2_offset_min = Column(Integer, nullable=True)

    time3 = Column(Time, nullable=True)
    time3_meal = Column(String(10), nullable=True)
    time3_offset_min = Column(Integer, nullable=True)

    time4 = Column(Time, nullable=True)
    time4_meal = Column(String(10), nullable=True)
    time4_offset_min = Column(Integer, nullable=True)

    time5 = Column(Time, nullable=True)
    time5_meal = Column(String(10), nullable=True)
    time5_offset_min = Column(Integer, nullable=True)

    time6 = Column(Time, nullable=True)
    time6_meal = Column(String(10), nullable=True)
    time6_offset_min = Column(Integer, nullable=True)

    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    is_indefinite = Column(Boolean, default=False, nullable=False)

    notes = Column(Text, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    user = relationship("User", back_populates="medications")


class PillboxStatus(Base):
    __tablename__ = "pillbox_status"

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)

    detected = Column(Boolean, default=False, nullable=False)  # 약 감지 여부
    battery_percent = Column(Integer, nullable=True)  # 0~100
    is_locked = Column(Boolean, default=False, nullable=False)

    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
