from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import Task
from schemas import TaskCreate, TaskUpdate, TaskResponse
from websocket.manager import manager
from websocket.events import TASK_ASSIGNED, TASK_UPDATED
from routers.auth import get_coordinator
router = APIRouter()


@router.post("/", response_model=TaskResponse)
async def create_task(task: TaskCreate, db: Session = Depends(get_db), coordinator=Depends(get_coordinator)):
    db_task = Task(**task.model_dump())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task


@router.get("/", response_model=list[TaskResponse])
def get_all_tasks(db: Session = Depends(get_db)):
    return db.query(Task).all()


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
async def accept_task(task_id: int, user_id: str, db: Session = Depends(get_db)):
    db_task = db.query(Task).filter(Task.id == task_id).first()
    db_task.status = "assigned"
    db_task.assigned_to = user_id
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