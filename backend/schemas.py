from pydantic import BaseModel, field_serializer
from typing import Optional
from datetime import datetime


# SOS
class SOSCreate(BaseModel):
    node_id: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    details: Optional[str] = None

class SOSResponse(BaseModel):
    id: int
    node_id: Optional[str]
    lat: Optional[float]
    lon: Optional[float]
    status: str
    created_at: datetime
    ai_score: Optional[float] = None
    ai_suggestion: Optional[str] = None

    @field_serializer("created_at")
    def serialize_dt(self, v): return v.strftime("%Y-%m-%d %H:%M:%S")

    class Config:
        from_attributes = True

class TaskAssignmentResponse(BaseModel):
    id: int
    task_id: int
    user_id: int
    status: str
    created_at: datetime

    @field_serializer("created_at")
    def serialize_dt(self, v): return v.strftime("%Y-%m-%d %H:%M:%S")

    class Config:
        from_attributes = True


# NeedRequest
class NeedRequestCreate(BaseModel):
    node_id: Optional[str] = None
    category: str
    lat: Optional[float] = None
    lon: Optional[float] = None
    people_count: int = 1
    details: Optional[str] = None

class NeedRequestResponse(BaseModel):
    id: int
    node_id: Optional[str]
    category: str
    lat: Optional[float]
    lon: Optional[float]
    people_count: int
    details: Optional[str]
    status: str
    created_at: datetime
    ai_score: Optional[float] = None
    ai_suggestion: Optional[str] = None

    @field_serializer("created_at")
    def serialize_dt(self, v): return v.strftime("%Y-%m-%d %H:%M:%S")

    class Config:
        from_attributes = True


class NeedStatusUpdate(BaseModel):
    status: str  # pending, assigned, resolved

# Task
class TaskCreate(BaseModel):
    title: str
    type: str
    lat: Optional[float] = None
    lon: Optional[float] = None

class TaskUpdate(BaseModel):
    status: Optional[str] = None
    assigned_to: Optional[str] = None

class TaskResponse(BaseModel):
    id: int
    title: str
    type: str
    status: str
    lat: Optional[float]
    lon: Optional[float]
    assigned_to: Optional[str]
    created_at: datetime
    priority_score: Optional[float] = None
    max_assignees: int = 1
    current_assignees: int = 0
    priority_score: Optional[float] = None
    max_assignees: int = 1
    current_assignees: int = 0

    @field_serializer("created_at")
    def serialize_dt(self, v): return v.strftime("%Y-%m-%d %H:%M:%S")

    class Config:
        from_attributes = True


# User
class UserCreate(BaseModel):
    name: str
    surname: str
    skills: Optional[str] = "GENERAL"
    phone: str
    blood_type: Optional[str] = None
    password: str
    skills: Optional[str] = "GENERAL"
    lat: Optional[float] = None
    lon: Optional[float] = None

class UserResponse(BaseModel):
    id: int
    name: str
    surname: str
    role: str
    phone: str
    blood_type: Optional[str]
    skills: Optional[str] = "GENERAL"
    lat: Optional[float] = None
    lon: Optional[float] = None
    active_task_id: Optional[int] = None
    active_task_id: Optional[int] = None

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    name: Optional[str] = None
    surname: Optional[str] = None
    blood_type: Optional[str] = None
    skills: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    password: Optional[str] = None
    phone: Optional[str] = None

# Auth
class Token(BaseModel):
    access_token: str
    token_type: str

class LoginRequest(BaseModel):
    phone: str
    password: str