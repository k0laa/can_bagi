from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import SOS
from schemas import SOSCreate, SOSResponse
from websocket.manager import manager
from websocket.events import NEW_SOS
import math
from datetime import datetime, timezone, timedelta
from routers.auth import get_coordinator
router = APIRouter()

def haversine(lat1, lon1, lat2, lon2):
    R = 6371000  # metre
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def calculate_score(sos, all_sos):
    score = 0

    # Bekleme süresi — her dakika +1
    now = datetime.now()
    diff = (now - sos.created_at).total_seconds() / 60
    score += diff

    # Konum var mı +10
    if sos.lat and sos.lon:
        score += 10

    # 100 metre içinde başka SOS var mı — her biri +5
    if sos.lat and sos.lon:
        for other in all_sos:
            if other.id == sos.id:
                continue
            if other.lat and other.lon:
                dist = haversine(sos.lat, sos.lon, other.lat, other.lon)
                if dist <= 100:
                    score += 5

    return score


@router.get("/prioritized")
def get_prioritized_sos(db: Session = Depends(get_db)):
    all_sos = db.query(SOS).filter(SOS.status == "active").all()

    scored = []
    for sos in all_sos:
        score = calculate_score(sos, all_sos)
        scored.append({
            "id": sos.id,
            "node_id": sos.node_id,
            "lat": sos.lat,
            "lon": sos.lon,
            "status": sos.status,
            "created_at": str(sos.created_at),
            "score": round(score, 2)
        })

    scored.sort(key=lambda x: x["score"], reverse=True)
    return scored


@router.post("/", response_model=SOSResponse)
async def create_sos(sos: SOSCreate, db: Session = Depends(get_db)):
    db_sos = SOS(**sos.model_dump())
    db.add(db_sos)
    db.commit()
    db.refresh(db_sos)

    await manager.broadcast_to_dashboard(NEW_SOS, {
        "id": db_sos.id,
        "node_id": db_sos.node_id,
        "lat": db_sos.lat,
        "lon": db_sos.lon,
        "status": db_sos.status,
        "created_at": str(db_sos.created_at)
    })

    return db_sos


@router.get("/", response_model=list[SOSResponse])
def get_all_sos(db: Session = Depends(get_db)):
    return db.query(SOS).all()


@router.get("/{sos_id}", response_model=SOSResponse)
def get_sos(sos_id: int, db: Session = Depends(get_db)):
    return db.query(SOS).filter(SOS.id == sos_id).first()


@router.delete("/{sos_id}")
async def delete_sos(sos_id: int, db: Session = Depends(get_db), coordinator=Depends(get_coordinator)):
    db_sos = db.query(SOS).filter(SOS.id == sos_id).first()
    if not db_sos:
        raise HTTPException(status_code=404, detail="SOS bulunamadı")
    db.delete(db_sos)
    db.commit()
    return {"status": "silindi"}

@router.put("/{sos_id}/resolve")
async def resolve_sos(sos_id: int, db: Session = Depends(get_db), coordinator=Depends(get_coordinator)):
    coordinator = Depends(get_coordinator)
    db_sos = db.query(SOS).filter(SOS.id == sos_id).first()
    if not db_sos:
        raise HTTPException(status_code=404, detail="SOS bulunamadı")
    db_sos.status = "resolved"
    db.commit()
    db.refresh(db_sos)

    await manager.broadcast_to_dashboard("SOS_RESOLVED", {
        "id": db_sos.id,
        "status": db_sos.status
    })

    return db_sos