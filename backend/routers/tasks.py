import math
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import Task, User
from schemas import TaskCreate, TaskUpdate, TaskResponse
from websocket.manager import manager
from websocket.events import TASK_ASSIGNED, TASK_UPDATED
from routers.auth import get_coordinator
from routers.auth import get_coordinator, get_current_user
router = APIRouter()


def haversine(lat1, lon1, lat2, lon2):
    R = 6371000
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi/2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))


def get_required_skill(task_type: str) -> str:
    mapping = {
        "MEDICAL": "MEDICAL",
        "RESCUE": "RESCUE",
        "LOGISTICS": "LOGISTICS",
    }
    return mapping.get(task_type, "GENERAL")


@router.get("/{task_id}/match")
def match_volunteer(task_id: int, db: Session = Depends(get_db)):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")
    if not task.lat or not task.lon:
        raise HTTPException(status_code=400, detail="Görevin konumu yok")

    required_skill = get_required_skill(task.type)

    if required_skill == "GENERAL":
        users = db.query(User).filter(User.role == "USER").all()
    else:
        users = db.query(User).filter(
            User.skills == required_skill,
            User.role == "USER"
        ).all()

    best_user = None
    best_dist = float("inf")

    for user in users:
        if user.lat and user.lon:
            dist = haversine(task.lat, task.lon, user.lat, user.lon)
            if dist < best_dist:
                best_dist = dist
                best_user = user

    if not best_user:
        return {"message": "Uygun gönüllü bulunamadı"}

    return {
        "task_id": task.id,
        "task_type": task.type,
        "matched_user": {
            "id": best_user.id,
            "name": best_user.name,
            "surname": best_user.surname,
            "phone": best_user.phone,
            "skills": best_user.skills,
            "distance_meters": round(best_dist, 2)
        }
    }


@router.post("/", response_model=TaskResponse)
async def create_task(task: TaskCreate, db: Session = Depends(get_db), coordinator=Depends(get_coordinator)):
    db_task = Task(**task.model_dump())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task


@router.get("/", response_model=list[TaskResponse])
def get_all_tasks(status: str = None, db: Session = Depends(get_db)):
    query = db.query(Task)
    if status:
        query = query.filter(Task.status == status)
    return query.all()


@router.get("/{task_id}", response_model=TaskResponse)
def get_task(task_id: int, db: Session = Depends(get_db)):
    return db.query(Task).filter(Task.id == task_id).first()


@router.put("/{task_id}", response_model=TaskResponse)
async def update_task(task_id: int, update: TaskUpdate, db: Session = Depends(get_db), coordinator=Depends(get_coordinator)):
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if update.status:
        db_task.status = update.status
    if update.assigned_to:
        db_task.assigned_to = update.assigned_to
    db.commit()
    db.refresh(db_task)

    event = TASK_ASSIGNED if update.assigned_to else TASK_UPDATED
    await manager.broadcast_to_all(event, {
        "id": db_task.id,
        "title": db_task.title,
        "status": db_task.status,
        "assigned_to": db_task.assigned_to,
        "created_at": str(db_task.created_at)
    })
    return db_task


@router.post("/{task_id}/accept")
async def accept_task(task_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")
    db_task.status = "assigned"
    db_task.assigned_to = str(current_user["sub"])
    db.commit()
    db.refresh(db_task)

    await manager.broadcast_to_all(TASK_ASSIGNED, {
        "id": db_task.id,
        "title": db_task.title,
        "status": db_task.status,
        "assigned_to": db_task.assigned_to
    })

    return db_task


@router.post("/{task_id}/complete")
async def complete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(Task).filter(Task.id == task_id).first()
    db_task.status = "completed"
    db.commit()
    db.refresh(db_task)

    await manager.broadcast_to_all(TASK_UPDATED, {
        "id": db_task.id,
        "title": db_task.title,
        "status": db_task.status
    })
    return db_task


@router.delete("/{task_id}")
async def delete_task(task_id: int, db: Session = Depends(get_db), coordinator=Depends(get_coordinator)):
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")
    db.delete(db_task)
    db.commit()
    return {"status": "silindi"}