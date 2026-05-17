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
def update_profile(
    update: UserUpdate = None,
    name: str = None,
    surname: str = None,
    blood_type: str = None,
    skills: str = None,
    lat: float = None,
    lon: float = None,
    phone: str = None,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    user = db.query(User).filter(User.id == int(current_user["sub"])).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")

    # Body'den veya query param'dan al
    _name = (update.name if update else None) or name
    _surname = (update.surname if update else None) or surname
    _blood_type = (update.blood_type if update else None) or blood_type
    _skills = (update.skills if update else None) or skills
    _lat = (update.lat if update else None) or lat
    _lon = (update.lon if update else None) or lon
    _phone = (update.phone if update else None) or phone

    if _name: user.name = _name
    if _surname: user.surname = _surname
    if _blood_type: user.blood_type = _blood_type
    if _skills: user.skills = _skills
    if _lat: user.lat = _lat
    if _lon: user.lon = _lon
    if _phone:
        existing = db.query(User).filter(User.phone == _phone).first()
        if existing and existing.id != int(current_user["sub"]):
            raise HTTPException(status_code=400, detail="Bu telefon numarası zaten kayıtlı")
        user.phone = _phone

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