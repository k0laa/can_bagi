from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import User
from schemas import UserResponse
from routers.auth import get_current_user

router = APIRouter()


@router.get("/profile", response_model=UserResponse)
def get_profile(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    user = db.query(User).filter(User.id == int(current_user["sub"])).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    return user


@router.put("/profile", response_model=UserResponse)
def update_profile(
    name: str = None,
    surname: str = None,
    blood_type: str = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    user = db.query(User).filter(User.id == int(current_user["sub"])).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")

    if name: user.name = name
    if surname: user.surname = surname
    if blood_type: user.blood_type = blood_type

    db.commit()
    db.refresh(user)
    return user