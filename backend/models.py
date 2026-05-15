from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func
from database import Base
from sqlalchemy import Boolean
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


class NeedRequest(Base):
    __tablename__ = "need_requests"

    id = Column(Integer, primary_key=True, index=True)
    node_id = Column(String, nullable=True)
    category = Column(String)  # MEDICAL, RESCUE, FOOD, SHELTER, CLOTHES, VULNERABLE
    lat = Column(Float, nullable=True)
    lon = Column(Float, nullable=True)
    people_count = Column(Integer, default=1)
    details = Column(String, nullable=True)
    status = Column(String, default="pending")  # pending, assigned, resolved
    created_at = Column(DateTime, default=turkey_time)


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    type = Column(String)  # FOOD, TRANSPORT, DISTRIBUTION, CLEANING, ESCORT, GUIDANCE
    status = Column(String, default="pending")  # pending, assigned, completed
    lat = Column(Float, nullable=True)
    lon = Column(Float, nullable=True)
    assigned_to = Column(String, nullable=True)
    created_at = Column(DateTime, default=turkey_time)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    surname = Column(String)
    phone = Column(String, unique=True)
    blood_type = Column(String, nullable=True)
    hashed_password = Column(String)
    created_at = Column(DateTime, default=func.now())
    is_coordinator = Column(Boolean, default=False)

class Node(Base):
    __tablename__ = "nodes"

    node_id = Column(String, primary_key=True)
    status = Column(String, default="active")
    free_heap = Column(Integer, nullable=True)
    last_seen = Column(DateTime, default=turkey_time)

