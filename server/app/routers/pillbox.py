from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..db import get_db
from .. import models
from ..schemas import PillboxStatusIn, PillboxStatusOut
from .auth import get_current_user_id

router = APIRouter()


@router.get("/status", response_model=PillboxStatusOut)
def get_status(user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    status = db.query(models.PillboxStatus).filter(models.PillboxStatus.user_id == user_id).first()
    if not status:
        status = models.PillboxStatus(user_id=user_id, detected=False, is_locked=False)
        db.add(status)
        db.commit()
        db.refresh(status)
    return PillboxStatusOut(
        detected=status.detected,
        battery_percent=status.battery_percent,
        is_locked=status.is_locked,
        updated_at=status.updated_at.isoformat() if status.updated_at else None,
    )


@router.post("/status", response_model=PillboxStatusOut)
def set_status(payload: PillboxStatusIn, user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    status = db.query(models.PillboxStatus).filter(models.PillboxStatus.user_id == user_id).first()
    if not status:
        status = models.PillboxStatus(user_id=user_id)
        db.add(status)
    status.detected = payload.detected
    status.battery_percent = payload.battery_percent
    status.is_locked = payload.is_locked
    db.commit()
    db.refresh(status)
    return PillboxStatusOut(
        detected=status.detected,
        battery_percent=status.battery_percent,
        is_locked=status.is_locked,
        updated_at=status.updated_at.isoformat() if status.updated_at else None,
    )
