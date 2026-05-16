from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from database import get_db
from models import User
from schemas import UserCreate, UserResponse, Token, LoginRequest
import bcrypt
from jose import jwt
from datetime import datetime, timedelta
from fastapi import Security

router = APIRouter()

SECRET_KEY = "meshaid-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_DAYS = 30

security = HTTPBearer()


def hash_password(password: str):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(plain: str, hashed: str):
    return bcrypt.checkpw(plain.encode(), hashed.encode())


def create_token(data: dict):
    expire = datetime.utcnow() + timedelta(days=ACCESS_TOKEN_EXPIRE_DAYS)
    data.update({"exp": expire})
    return jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)


def get_current_user(credentials: HTTPAuthorizationCredentials = Security(security)):
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except:
        raise HTTPException(status_code=401, detail="Geçersiz token")


def get_coordinator(credentials: HTTPAuthorizationCredentials = Security(security)):
    payload = get_current_user(credentials)
    if payload.get("role") not in ["COORDINATOR", "SUPER"]:
        raise HTTPException(status_code=403, detail="Koordinatör yetkisi gerekli")
    return payload


def get_super(credentials: HTTPAuthorizationCredentials = Security(security)):
    payload = get_current_user(credentials)
    if payload.get("role") != "SUPER":
        raise HTTPException(status_code=403, detail="Süper koordinatör yetkisi gerekli")
    return payload


@router.post("/register", response_model=UserResponse)
def register(user: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.phone == user.phone).first()
    if existing:
        raise HTTPException(status_code=400, detail="Bu telefon zaten kayıtlı")

    db_user = User(
        name=user.name,
        surname=user.surname,
        phone=user.phone,
        blood_type=user.blood_type,
        skills=user.skills,
        hashed_password=hash_password(user.password)
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@router.post("/login", response_model=Token)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone == data.phone).first()
    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Telefon veya şifre hatalı")

    token = create_token({"sub": str(user.id), "phone": user.phone, "role": user.role})
    return {"access_token": token, "token_type": "bearer"}


@router.post("/coordinator/login", response_model=Token)
def coordinator_login(data: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone == data.phone).first()
    if not user or not verify_password(data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Telefon veya şifre hatalı")
    if user.role not in ["COORDINATOR", "SUPER"]:
        raise HTTPException(status_code=403, detail="Koordinatör yetkisi yok")

    token = create_token({"sub": str(user.id), "phone": user.phone, "role": user.role})
    return {"access_token": token, "token_type": "bearer"}


@router.post("/make-coordinator/{user_id}")
def make_coordinator(user_id: int, db: Session = Depends(get_db), current=Depends(get_super)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    if user.role == "SUPER":
        raise HTTPException(status_code=400, detail="Süper koordinatör değiştirilemez")
    user.role = "COORDINATOR"
    db.commit()
    return {"status": "ok", "user_id": user_id, "role": "COORDINATOR"}


@router.post("/make-user/{user_id}")
def make_user(user_id: int, db: Session = Depends(get_db), current=Depends(get_super)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    if user.role == "SUPER":
        raise HTTPException(status_code=400, detail="Süper koordinatör değiştirilemez")
    user.role = "USER"
    db.commit()
    return {"status": "ok", "user_id": user_id, "role": "USER"}