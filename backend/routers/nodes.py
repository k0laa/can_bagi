from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from websocket.manager import manager
from models import Node, turkey_time
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
    print("Ham veri:", data)
    await manager.broadcast_to_dashboard("RAW_DATA", data)
    return {"status": "ok"}


@router.get("/")
def get_nodes(db: Session = Depends(get_db)):
    return db.query(Node).all()