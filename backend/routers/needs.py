from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import NeedRequest
from schemas import NeedRequestCreate, NeedRequestResponse
from websocket.manager import manager
from websocket.events import NEW_REQUEST
from fastapi import APIRouter, Depends, HTTPException
from routers.auth import get_coordinator
from schemas import NeedRequestCreate, NeedRequestResponse, NeedStatusUpdate

router = APIRouter()


@router.post("/", response_model=NeedRequestResponse)
async def create_need(need: NeedRequestCreate, db: Session = Depends(get_db)):
    db_need = NeedRequest(**need.model_dump())
    db.add(db_need)
    db.commit()
    db.refresh(db_need)

    await manager.broadcast_to_dashboard(NEW_REQUEST, {
        "id": db_need.id,
        "node_id": db_need.node_id,
        "category": db_need.category,
        "lat": db_need.lat,
        "lon": db_need.lon,
        "people_count": db_need.people_count,
        "details": db_need.details,
        "status": db_need.status,
        "created_at": str(db_need.created_at)
    })

    return db_need


@router.get("/", response_model=list[NeedRequestResponse])
def get_all_needs(status: str = None, db: Session = Depends(get_db)):
    query = db.query(NeedRequest)
    if status:
        query = query.filter(NeedRequest.status == status)
    return query.all()


@router.get("/{need_id}", response_model=NeedRequestResponse)
def get_need(need_id: int, db: Session = Depends(get_db)):
    return db.query(NeedRequest).filter(NeedRequest.id == need_id).first()


@router.put("/{need_id}/status")
def update_status(need_id: int, update: NeedStatusUpdate, db: Session = Depends(get_db)):
    db_need = db.query(NeedRequest).filter(NeedRequest.id == need_id).first()
    if not db_need:
        raise HTTPException(status_code=404, detail="İhtiyaç bulunamadı")
    db_need.status = update.status
    db.commit()
    db.refresh(db_need)
    return db_need

@router.delete("/{need_id}")
async def delete_need(need_id: int, db: Session = Depends(get_db), coordinator=Depends(get_coordinator)):
    coordinator = Depends(get_coordinator)
    db_need = db.query(NeedRequest).filter(NeedRequest.id == need_id).first()
    if not db_need:
        raise HTTPException(status_code=404, detail="İhtiyaç bulunamadı")
    db.delete(db_need)
    db.commit()
    return {"status": "silindi"}