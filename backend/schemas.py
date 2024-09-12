from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, date
from fastapi.security import OAuth2PasswordRequestForm


class UserModel(BaseModel):
    user_id: int
    username: str
    surname: Optional[str]
    name: Optional[str]
    middle_name: Optional[str]
    hire_date: Optional[date]
    phone_number: Optional[str]
    birth_date: Optional[date]
    email: Optional[str]
    fcm_token: Optional[List[str]]
    role_id: int
    shift_id: Optional[int]
    specialization: Optional[str] = None
    request_type: int

    class Config:
        from_attributes = True

class StatusModel(BaseModel):
    status_id: int
    status_name: str

    class Config:
        from_attributes = True

class LoginRequest(OAuth2PasswordRequestForm):
    fcm_token: Optional[str] = None

class LoginResponse(BaseModel):
    user_id: int
    role_id: int
    access_token: str

class RegisterRequest(BaseModel):
    username: str
    password: str
    surname: Optional[str] = None
    name: Optional[str] = None
    middle_name: Optional[str] = None
    hire_date: Optional[date] = None
    phone_number: Optional[str] = None
    birth_date: Optional[date] = None
    email: Optional[str] = None
    role_id: int
    specialization: Optional[str] = None
    request_type: int

class RequestModel(BaseModel):
    request_id: int
    request_type: int
    created_by: int
    assigned_to: Optional[int]
    area_id: int
    description: str
    status_id: int
    created_at: datetime
    updated_at: Optional[datetime]
    reason: Optional[str]

    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.strftime("%Y-%m-%dT%H:%M:%S")
        }

class RequestCreate(BaseModel):
    request_type: int
    user_id: int
    area_id: int
    description: str

class UpdateRequest(BaseModel):
    user_id: int
    request_id: int
    reason: Optional[str] = Field(default=None)

class RequestTypeModel(BaseModel):
    request_type: int
    type_name: str

    class Config:
        from_attributes = True

class RoleModel(BaseModel):
    role_id: int
    role_name: str

    class Config:
        from_attributes = True

class RequestStatusLogModel(BaseModel):
    log_id: int
    request_id: int
    old_status_id: Optional[int]
    new_status_id: int
    changed_at: datetime
    changed_by: int
    reason: Optional[str]
    changer_name: Optional[str] = None   # Set default value
    action_name: Optional[str] = None    # Set default value

    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.strftime("%Y-%m-%dT%H:%M:%S")
        }

class RewardsResponse(BaseModel):
    tokens: int
    num_created: int
    num_completed: int
    last_completed: Optional[date]

    class Config:
        from_attributes = True

class RefreshTokenRequest(BaseModel):
    user_id: int
    new_fcm: str

class LogoutRequest(BaseModel):
    user_id: int
    old_fcm: str

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: str | None = None