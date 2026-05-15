from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import SOS
from schemas import SOSCreate, SOSResponse
from websocket.manager import manager
from websocket.events import NEW_SOS

router = APIRouter()


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
async def delete_sos(sos_id: int, db: Session = Depends(get_db)):
    db_sos = db.query(SOS).filter(SOS.id == sos_id).first()
    if not db_sos:
        raise HTTPException(status_code=404, detail="SOS bulunamadı")
    db.delete(db_sos)
    db.commit()
    return {"status": "silindi"}

@router.put("/{sos_id}/resolve")
async def resolve_sos(sos_id: int, db: Session = Depends(get_db)):
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