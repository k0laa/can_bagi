from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import User
from schemas import UserResponse
from routers.auth import get_current_user
from routers.auth import get_current_user, get_coordinator
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
def update_profile(
        name: str = None,
        surname: str = None,
        blood_type: str = None,
        lat: float = None,
        lon: float = None,
        db: Session = Depends(get_db),
        current_user=Depends(get_current_user),
):
    user = db.query(User).filter(User.id == int(current_user["sub"])).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    if name: user.name = name
    if surname: user.surname = surname
    if blood_type: user.blood_type = blood_type
    if lat: user.lat = lat
    if lon: user.lon = lon
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