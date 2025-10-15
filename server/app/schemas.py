from datetime import date, time
from pydantic import BaseModel, EmailStr, Field
from typing import Optional


class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6)
    name: Optional[str] = None
    age: Optional[int] = None
    address: Optional[str] = None
    gender: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    id: int
    email: EmailStr
    name: Optional[str]
    age: Optional[int] = None
    address: Optional[str] = None
    gender: Optional[str] = None

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class MedicationBase(BaseModel):
    name: str
    daily_count: int = Field(ge=1, le=6)

    time1: Optional[time] = None
    time1_meal: Optional[str] = None
    time1_offset_min: Optional[int] = None

    time2: Optional[time] = None
    time2_meal: Optional[str] = None
    time2_offset_min: Optional[int] = None

    time3: Optional[time] = None
    time3_meal: Optional[str] = None
    time3_offset_min: Optional[int] = None

    time4: Optional[time] = None
    time4_meal: Optional[str] = None
    time4_offset_min: Optional[int] = None

    time5: Optional[time] = None
    time5_meal: Optional[str] = None
    time5_offset_min: Optional[int] = None

    time6: Optional[time] = None
    time6_meal: Optional[str] = None
    time6_offset_min: Optional[int] = None

    start_date: date
    end_date: Optional[date] = None
    is_indefinite: bool = False

    notes: Optional[str] = None


class MedicationCreate(BaseModel):
    name: str
    daily_count: int = Field(ge=1, le=6)

    time1: Optional[time] = None
    time1_meal: Optional[str] = None
    time1_offset_min: Optional[int] = None

    time2: Optional[time] = None
    time2_meal: Optional[str] = None
    time2_offset_min: Optional[int] = None

    time3: Optional[time] = None
    time3_meal: Optional[str] = None
    time3_offset_min: Optional[int] = None

    time4: Optional[time] = None
    time4_meal: Optional[str] = None
    time4_offset_min: Optional[int] = None

    time5: Optional[time] = None
    time5_meal: Optional[str] = None
    time5_offset_min: Optional[int] = None

    time6: Optional[time] = None
    time6_meal: Optional[str] = None
    time6_offset_min: Optional[int] = None

    start_date: date
    end_date: Optional[date] = None
    is_indefinite: bool = False

    notes: Optional[str] = None


class MedicationUpdate(MedicationBase):
    pass


class MedicationOut(MedicationBase):
    id: int

    class Config:
        from_attributes = True


class PillboxStatusIn(BaseModel):
    detected: bool
    battery_percent: Optional[int] = None
    is_locked: bool


class PillboxStatusOut(BaseModel):
    detected: bool
    battery_percent: Optional[int] = None
    is_locked: bool
    updated_at: Optional[str] = None


class AiChatRequest(BaseModel):
    message: str


class AiChatResponse(BaseModel):
    reply: str


class AiFeedbackRequest(BaseModel):
    itemName: Optional[str] = None
    entpName: Optional[str] = None
    question: Optional[str] = None
    context: Optional[str] = None


class AiFeedbackResponse(BaseModel):
    product_name: Optional[str] = None
    answer_type: str
    answer: str
    source: str
