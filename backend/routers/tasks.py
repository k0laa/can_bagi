import math
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
from models import Task, User
from schemas import TaskCreate, TaskUpdate, TaskResponse
from websocket.manager import manager
from websocket.events import TASK_ASSIGNED, TASK_UPDATED
from routers.auth import get_coordinator
from routers.auth import get_coordinator, get_current_user
=======
>>>>>>> Stashed changes
from models import Task, User, TaskAssignment
from schemas import TaskCreate, TaskUpdate, TaskResponse
from websocket.manager import manager
from websocket.events import TASK_ASSIGNED, TASK_UPDATED
from routers.auth import get_coordinator, get_current_user
from ai_service import create_task_with_ai

<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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


<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
async def auto_assign_task(event_type: str, event_data: dict, db: Session):
    users = db.query(User).filter(
        User.role == "USER",
        User.active_task_id == None
    ).all()

    if not users:
        print("Müsait kullanıcı yok")
        return

    user_list = [{
        "id": u.id,
        "name": u.name,
        "skills": u.skills,
        "lat": u.lat,
        "lon": u.lon,
        "active_task_id": u.active_task_id
    } for u in users if u.lat and u.lon]

    if not user_list:
        print("Konumu olan müsait kullanıcı yok")
        return

    try:
        ai_result = create_task_with_ai(event_type, event_data, user_list)
    except Exception as e:
        print("AI görev oluşturma hatası:", e)
        return

    if "error" in ai_result:
        print("AI hatası:", ai_result["error"])
        return

    db_task = Task(
        title=ai_result["title"],
        type=ai_result["type"],
        lat=event_data.get("lat") or None,
        lon=event_data.get("lon") or None,
        priority_score=ai_result.get("priority_score"),
        max_assignees=ai_result.get("max_assignees", 1),
        current_assignees=len(ai_result.get("assigned_user_ids", []))
    )
    db.add(db_task)
    db.commit()
    db.refresh(db_task)

    for user_id in ai_result["assigned_user_ids"]:
        assignment = TaskAssignment(
            task_id=db_task.id,
            user_id=user_id,
            status="pending"
        )
        db.add(assignment)

        user = db.query(User).filter(User.id == user_id).first()
        if user:
            user.active_task_id = db_task.id

    db.commit()

    await manager.broadcast_to_dashboard("TASK_ASSIGNED", {
        "id": db_task.id,
        "title": db_task.title,
        "type": db_task.type,
        "priority_score": db_task.priority_score,
        "assigned_user_ids": ai_result["assigned_user_ids"]
    })

    await manager.broadcast_to_mobile(TASK_ASSIGNED, {
        "id": db_task.id,
        "title": db_task.title,
        "type": db_task.type,
        "lat": db_task.lat,
        "lon": db_task.lon
    })

    print(f"Görev oluşturuldu: {db_task.title}, {len(ai_result['assigned_user_ids'])} kişiye atandı")


@router.get("/my")
def get_my_tasks(db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    user_id = int(current_user["sub"])
    assignments = db.query(TaskAssignment).filter(
        TaskAssignment.user_id == user_id,
        TaskAssignment.status.in_(["pending", "accepted"])
    ).all()
    task_ids = [a.task_id for a in assignments]
    tasks = db.query(Task).filter(Task.id.in_(task_ids)).all()
    return tasks


@router.get("/prioritized")
def get_prioritized_tasks(db: Session = Depends(get_db)):
    return db.query(Task).filter(
        Task.status != "completed"
    ).order_by(Task.priority_score.desc()).all()


<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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


<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
@router.get("/{task_id}/assignments")
def get_task_assignments(task_id: int, db: Session = Depends(get_db), coordinator=Depends(get_coordinator)):
    return db.query(TaskAssignment).filter(TaskAssignment.task_id == task_id).all()


<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")
    db_task.status = "assigned"
    db_task.assigned_to = str(current_user["sub"])
=======
>>>>>>> Stashed changes
    user_id = int(current_user["sub"])
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")

    assignment = db.query(TaskAssignment).filter(
        TaskAssignment.task_id == task_id,
        TaskAssignment.user_id == user_id
    ).first()

    if not assignment:
        raise HTTPException(status_code=403, detail="Bu göreve atanmadınız")

    assignment.status = "accepted"
    db_task.assigned_to = str(user_id)
    db_task.status = "assigned"

    user = db.query(User).filter(User.id == user_id).first()
    if user:
        user.active_task_id = task_id

<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
>>>>>>> Stashed changes
    db.commit()
    db.refresh(db_task)

    await manager.broadcast_to_all(TASK_ASSIGNED, {
        "id": db_task.id,
        "title": db_task.title,
        "status": db_task.status,
        "assigned_to": db_task.assigned_to
    })
<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream

    return db_task


@router.post("/{task_id}/complete")
async def complete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(Task).filter(Task.id == task_id).first()
    db_task.status = "completed"
=======
>>>>>>> Stashed changes
    return db_task


@router.post("/{task_id}/reject")
async def reject_task(task_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    user_id = int(current_user["sub"])

    assignment = db.query(TaskAssignment).filter(
        TaskAssignment.task_id == task_id,
        TaskAssignment.user_id == user_id,
        TaskAssignment.status == "pending"
    ).first()

    if not assignment:
        raise HTTPException(status_code=404, detail="Atama bulunamadı")

    assignment.status = "rejected"

    task = db.query(Task).filter(Task.id == task_id).first()
    task.current_assignees -= 1

    user = db.query(User).filter(User.id == user_id).first()
    if user:
        user.active_task_id = None

    db.commit()

    await manager.broadcast_to_dashboard("TASK_REJECTED", {
        "task_id": task_id,
        "user_id": user_id
    })

    return {"status": "reddedildi"}


@router.post("/{task_id}/complete")
async def complete_task(task_id: int, db: Session = Depends(get_db), current_user=Depends(get_current_user)):
    user_id = int(current_user["sub"])
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")

    db_task.status = "completed"

    user = db.query(User).filter(User.id == user_id).first()
    if user:
        user.active_task_id = None
        db.flush()

    assignment = db.query(TaskAssignment).filter(
        TaskAssignment.task_id == task_id,
        TaskAssignment.user_id == user_id
    ).first()
    if assignment:
        assignment.status = "completed"

<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
>>>>>>> Stashed changes
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