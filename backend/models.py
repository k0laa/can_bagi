from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func
from database import Base
from datetime import datetime, timezone, timedelta

def turkey_time():
    now = datetime.now(timezone(timedelta(hours=3)))
    return now.replace(microsecond=0, tzinfo=None)

class SOS(Base):
    __tablename__ = "sos"

    id = Column(Integer, primary_key=True, index=True)
    node_id = Column(String, nullable=True)
    lat = Column(Float, nullable=True)
    lon = Column(Float, nullable=True)
    status = Column(String, default="active")
    created_at = Column(DateTime, default=turkey_time)
    ai_score = Column(Float, nullable=True)
    ai_suggestion = Column(String, nullable=True)
    details = Column(String, nullable=True)


class NeedRequest(Base):
    __tablename__ = "need_requests"

    id = Column(Integer, primary_key=True, index=True)
    node_id = Column(String, nullable=True)
    category = Column(String)
    lat = Column(Float, nullable=True)
    lon = Column(Float, nullable=True)
    people_count = Column(Integer, default=1)
    details = Column(String, nullable=True)
    status = Column(String, default="pending")
    created_at = Column(DateTime, default=turkey_time)
    ai_score = Column(Float, nullable=True)
    ai_suggestion = Column(String, nullable=True)


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    type = Column(String)
    status = Column(String, default="pending")
    lat = Column(Float, nullable=True)
    lon = Column(Float, nullable=True)
    assigned_to = Column(String, nullable=True)
    created_at = Column(DateTime, default=turkey_time)
    priority_score = Column(Float, nullable=True)
    max_assignees = Column(Integer, default=1)
    current_assignees = Column(Integer, default=0)

class TaskAssignment(Base):
    __tablename__ = "task_assignments"

    id = Column(Integer, primary_key=True, index=True)
    task_id = Column(Integer, nullable=False)
    user_id = Column(Integer, nullable=False)
    status = Column(String, default="pending")  # pending, accepted, rejected
    created_at = Column(DateTime, default=turkey_time)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    surname = Column(String)
    phone = Column(String, unique=True)
    blood_type = Column(String, nullable=True)
    hashed_password = Column(String)
    created_at = Column(DateTime, default=turkey_time)
    role = Column(String, default="USER")  # USER, COORDINATOR, SUPER
    skills = Column(String, nullable=True, default="GENERAL")
    lat = Column(Float, nullable=True)
    lon = Column(Float, nullable=True)
    active_task_id = Column(Integer, nullable=True)


class Node(Base):
    __tablename__ = "nodes"

    node_id = Column(String, primary_key=True)
    status = Column(String, default="active")
    free_heap = Column(Integer, nullable=True)
    last_seen = Column(DateTime, default=turkey_time)