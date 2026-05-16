from pydantic import BaseModel, field_serializer
from typing import Optional
from datetime import datetime


# SOS
class SOSCreate(BaseModel):
    node_id: Optional[str] = None
    lat: Optional[float] = None
    lon: Optional[float] = None

class SOSResponse(BaseModel):
    id: int
    node_id: Optional[str]
    lat: Optional[float]
    lon: Optional[float]
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

    @field_serializer("created_at")
    def serialize_dt(self, v): return v.strftime("%Y-%m-%d %H:%M:%S")

    class Config:
        from_attributes = True


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

    class Config:
        from_attributes = True


# Auth
class Token(BaseModel):
    access_token: str
    token_type: str

class LoginRequest(BaseModel):
    phone: str
    password: str