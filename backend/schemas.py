from pydantic import BaseModel
from typing import Optional


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
    created_at: str

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
    created_at: str

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
    created_at: str

    class Config:
        from_attributes = True


# User
class UserCreate(BaseModel):
    name: str
    surname: str
    phone: str
    blood_type: Optional[str] = None
    password: str

class UserResponse(BaseModel):
    id: int
    name: str
    surname: str
    phone: str
    blood_type: Optional[str]
    is_coordinator: bool

    class Config:
        from_attributes = True


# Auth
class Token(BaseModel):
    access_token: str
    token_type: str

class LoginRequest(BaseModel):
    phone: str
    password: str