from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from websocket.manager import manager
from models import Node, turkey_time
from fastapi import APIRouter, Depends, HTTPException
from models import SOS, NeedRequest
from schemas import SOSCreate, NeedRequestCreate
from websocket.events import NEW_SOS, NEW_REQUEST
router = APIRouter()


@router.post("/heartbeat")
async def heartbeat(data: dict, db: Session = Depends(get_db)):
    node_id = data.get("node_id")
    if not node_id:
        return {"error": "node_id gerekli"}

    node = db.query(Node).filter(Node.node_id == node_id).first()
    if node:
        node.status = "active"
        node.free_heap = data.get("free_heap")
        node.last_seen = turkey_time()
    else:
        node = Node(
            node_id=node_id,
            free_heap=data.get("free_heap")
        )
        db.add(node)

    db.commit()

    await manager.broadcast_to_dashboard("NODE_STATUS", {
        "node_id": node_id,
        "status": "active",
        "free_heap": data.get("free_heap"),
        "last_seen": str(node.last_seen)
    })

    return {"status": "ok"}


@router.post("/data")
async def receive_data(data: dict, db: Session = Depends(get_db)):
    msg_type = data.get("type")

    if msg_type == "SOS":
        db_sos = SOS(
            node_id=data.get("node_id"),
            lat=data.get("lat"),
            lon=data.get("lon")
        )
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

    elif msg_type in ["NEEDS", "REQUEST"]:
        db_need = NeedRequest(
            node_id=data.get("node_id"),
            category=data.get("category"),
            lat=data.get("lat"),
            lon=data.get("lon"),
            people_count=data.get("people_count", 1),
            details=data.get("details")
        )
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

    else:
        print("Bilinmeyen tip:", data)

    return {"status": "ok"}

@router.get("/{node_id}")
def get_node(node_id: str, db: Session = Depends(get_db)):
    node = db.query(Node).filter(Node.node_id == node_id).first()
    if not node:
        raise HTTPException(status_code=404, detail="Node bulunamadı")
    return node


@router.delete("/{node_id}")
async def delete_node(node_id: str, db: Session = Depends(get_db)):
    node = db.query(Node).filter(Node.node_id == node_id).first()
    if not node:
        raise HTTPException(status_code=404, detail="Node bulunamadı")
    db.delete(node)
    db.commit()
    return {"status": "silindi"}


@router.get("/")
def get_nodes(db: Session = Depends(get_db)):
    return db.query(Node).all()