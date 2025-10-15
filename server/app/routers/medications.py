from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..db import get_db
from .. import models
from ..schemas import MedicationCreate, MedicationUpdate, MedicationOut
from .auth import get_current_user_id

router = APIRouter()


@router.get("/", response_model=list[MedicationOut])
def list_medications(user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    items = db.query(models.Medication).filter(models.Medication.user_id == user_id).all()
    return items


@router.post("/", response_model=MedicationOut)
def create_medication(payload: MedicationCreate, user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    item = models.Medication(user_id=user_id, **payload.dict())
    db.add(item)
    db.commit()
    db.refresh(item)
    return item


@router.get("/{med_id}", response_model=MedicationOut)
def get_medication(med_id: int, user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    item = db.query(models.Medication).filter(models.Medication.id == med_id, models.Medication.user_id == user_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Not found")
    return item


@router.put("/{med_id}", response_model=MedicationOut)
def update_medication(med_id: int, payload: MedicationUpdate, user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    item = db.query(models.Medication).filter(models.Medication.id == med_id, models.Medication.user_id == user_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Not found")
    for k, v in payload.dict().items():
        setattr(item, k, v)
    db.commit()
    db.refresh(item)
    return item


@router.delete("/{med_id}")
def delete_medication(med_id: int, user_id: int = Depends(get_current_user_id), db: Session = Depends(get_db)):
    item = db.query(models.Medication).filter(models.Medication.id == med_id, models.Medication.user_id == user_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Not found")
    db.delete(item)
    db.commit()
    return {"ok": True}
