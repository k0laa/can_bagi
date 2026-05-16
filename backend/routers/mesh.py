from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import Task, User, TaskAssignment
from websocket.manager import manager
from websocket.events import TASK_ASSIGNED, TASK_UPDATED
from jose import jwt

router = APIRouter()

SECRET_KEY = "meshaid-secret-key"
ALGORITHM = "HS256"


def get_user_from_token(token: str, db: Session):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = int(payload.get("sub"))
        return db.query(User).filter(User.id == user_id).first()
    except:
        return None


@router.post("/tasks/my/request")
async def get_my_tasks_mesh(data: dict, db: Session = Depends(get_db)):
    token = data.get("token")
    user = get_user_from_token(token, db)
    if not user:
        raise HTTPException(status_code=401, detail="Geçersiz token")

    assignments = db.query(TaskAssignment).filter(
        TaskAssignment.user_id == user.id,
        TaskAssignment.status.in_(["pending", "accepted"])
    ).all()

    task_ids = [a.task_id for a in assignments]
    tasks = db.query(Task).filter(Task.id.in_(task_ids)).all()

    task_list = [{
        "id": t.id,
        "title": t.title,
        "type": t.type,
        "status": t.status,
        "lat": t.lat,
        "lon": t.lon,
        "priority_score": t.priority_score,
    } for t in tasks]

    await manager.broadcast_to_mobile("YOUR_TASKS", {
        "user_id": user.id,
        "tasks": task_list
    })

    return {"status": "ok"}


@router.post("/tasks/accept")
async def accept_task_mesh(data: dict, db: Session = Depends(get_db)):
    token = data.get("token")
    task_id = data.get("task_id")
    user = get_user_from_token(token, db)
    if not user:
        raise HTTPException(status_code=401, detail="Geçersiz token")

    assignment = db.query(TaskAssignment).filter(
        TaskAssignment.task_id == task_id,
        TaskAssignment.user_id == user.id
    ).first()
    if not assignment:
        raise HTTPException(status_code=403, detail="Bu göreve atanmadınız")

    assignment.status = "accepted"
    task = db.query(Task).filter(Task.id == task_id).first()
    task.status = "assigned"
    task.assigned_to = str(user.id)
    user.active_task_id = task_id
    db.commit()

    await manager.broadcast_to_dashboard(TASK_ASSIGNED, {
        "id": task.id,
        "title": task.title,
        "status": task.status,
        "assigned_to": task.assigned_to
    })

    await manager.broadcast_to_mobile("TASK_ACTION_RESULT", {
        "task_id": task_id,
        "action": "accepted",
        "status": "ok"
    })

    return {"status": "ok"}


@router.post("/tasks/reject")
async def reject_task_mesh(data: dict, db: Session = Depends(get_db)):
    token = data.get("token")
    task_id = data.get("task_id")
    user = get_user_from_token(token, db)
    if not user:
        raise HTTPException(status_code=401, detail="Geçersiz token")

    assignment = db.query(TaskAssignment).filter(
        TaskAssignment.task_id == task_id,
        TaskAssignment.user_id == user.id,
        TaskAssignment.status == "pending"
    ).first()
    if not assignment:
        raise HTTPException(status_code=404, detail="Atama bulunamadı")

    assignment.status = "rejected"
    task = db.query(Task).filter(Task.id == task_id).first()
    task.current_assignees -= 1
    user.active_task_id = None
    db.commit()

    await manager.broadcast_to_dashboard("TASK_REJECTED", {
        "task_id": task_id,
        "user_id": user.id
    })

    await manager.broadcast_to_mobile("TASK_ACTION_RESULT", {
        "task_id": task_id,
        "action": "rejected",
        "status": "ok"
    })

    return {"status": "ok"}


@router.post("/tasks/complete")
async def complete_task_mesh(data: dict, db: Session = Depends(get_db)):
    token = data.get("token")
    task_id = data.get("task_id")
    user = get_user_from_token(token, db)
    if not user:
        raise HTTPException(status_code=401, detail="Geçersiz token")

    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")

    task.status = "completed"
    user.active_task_id = None
    db.flush()

    assignment = db.query(TaskAssignment).filter(
        TaskAssignment.task_id == task_id,
        TaskAssignment.user_id == user.id
    ).first()
    if assignment:
        assignment.status = "completed"

    db.commit()

    await manager.broadcast_to_dashboard(TASK_UPDATED, {
        "id": task.id,
        "title": task.title,
        "status": task.status
    })

    await manager.broadcast_to_mobile("TASK_ACTION_RESULT", {
        "task_id": task_id,
        "action": "completed",
        "status": "ok"
    })

    return {"status": "ok"}


@router.post("/user/profile/request")
async def get_profile_mesh(data: dict, db: Session = Depends(get_db)):
    token = data.get("token")
    user = get_user_from_token(token, db)
    if not user:
        raise HTTPException(status_code=401, detail="Geçersiz token")

    await manager.broadcast_to_mobile("USER_PROFILE", {
        "id": user.id,
        "name": user.name,
        "surname": user.surname,
        "phone": user.phone,
        "blood_type": user.blood_type,
        "skills": user.skills,
        "lat": user.lat,
        "lon": user.lon,
        "active_task_id": user.active_task_id,
        "role": user.role
    })

    return {"status": "ok"}