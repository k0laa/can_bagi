from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import User
from schemas import UserResponse
from routers.auth import get_current_user
from routers.auth import get_current_user, get_coordinator
from schemas import UserResponse, UserUpdate
from routers.auth import get_current_user, get_coordinator, hash_password
router = APIRouter()


@router.get("/", response_model=list[UserResponse])
def get_all_users(db: Session = Depends(get_db), current_user=Depends(get_coordinator)):
    return db.query(User).all()

@router.get("/profile", response_model=UserResponse)
def get_profile(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    user = db.query(User).filter(User.id == int(current_user["sub"])).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    return user


    if name: user.name = name


@router.put("/profile", response_model=UserResponse)
def update_profile(update: UserUpdate, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    user = db.query(User).filter(User.id == int(current_user["sub"])).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")

    if update.name: user.name = update.name
    if update.surname: user.surname = update.surname
    if update.blood_type: user.blood_type = update.blood_type
    if update.skills: user.skills = update.skills
    if update.lat: user.lat = update.lat
    if update.lon: user.lon = update.lon
    if update.password: user.hashed_password = hash_password(update.password)
    if update.phone:
        existing = db.query(User).filter(User.phone == update.phone).first()
        if existing and existing.id != int(current_user["sub"]):
            raise HTTPException(status_code=400, detail="Bu telefon numarası zaten kayıtlı")
        user.phone = update.phone

    db.commit()
    db.refresh(user)
    return user


@router.delete("/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db), current_user=Depends(get_coordinator)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    db.delete(user)
    db.commit()
    return {"status": "silindi"}