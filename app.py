import os
from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.types import TIMESTAMP, String
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from pydantic import BaseModel
from dotenv import load_dotenv
from datetime import datetime, timezone
from typing import List, Optional
from firebase_admin import credentials, initialize_app
from google.oauth2 import service_account
import google.auth.transport.requests
import requests
import json

load_dotenv()

DATABASE_USER = os.getenv("DATABASE_USER")
DATABASE_PASSWORD = os.getenv("DATABASE_PASSWORD")
DATABASE_HOST = os.getenv("DATABASE_HOST")
DATABASE_PORT = os.getenv("DATABASE_PORT")
DATABASE_NAME = os.getenv("DATABASE_NAME")

DATABASE_URL = f"postgresql+psycopg2://{DATABASE_USER}:{DATABASE_PASSWORD}@{DATABASE_HOST}:{DATABASE_PORT}/{DATABASE_NAME}"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

app = FastAPI()

# Table models

class User(Base):
    __tablename__ = 'users'
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    surname = Column(String)
    name = Column(String)
    spec_id = Column(Integer, ForeignKey('specializations.spec_id'), nullable=True)
    fcm_token = Column(String, nullable=True)
    role_id = Column(Integer, ForeignKey('roles.role_id'))
    shift_id = Column(Integer, ForeignKey('worker_shifts.shift_id'))

    role = relationship("Role", back_populates="users")
    shift = relationship("WorkerShift", back_populates="users")

class Specialization(Base):
    __tablename__ = 'specializations'
    spec_id = Column(Integer, primary_key=True, index=True)
    spec_name = Column(String, unique=True, index=True, nullable=False)

    users = relationship("User", back_populates="specialization")

User.specialization = relationship("Specialization", back_populates="users")

class Role(Base):
    __tablename__ = 'roles'
    role_id = Column(Integer, primary_key=True, index=True)
    role_name = Column(String, unique=True, index=True, nullable=False)
    
    users = relationship("User", back_populates="role")

class WorkerShift(Base):
    __tablename__ = 'worker_shifts'
    shift_id = Column(Integer, primary_key=True, index=True)
    start_time = Column(String, nullable=False)
    end_time = Column(String, nullable=False)
    
    users = relationship("User", back_populates="shift")

class RequestType(Base):
    __tablename__ = 'request_types'
    request_type = Column(Integer, primary_key=True, index=True)
    type_name = Column(String, unique=True, index=True, nullable=False)

class Area(Base):
    __tablename__ = 'areas'
    area_id = Column(Integer, primary_key=True, index=True)
    area_name = Column(String, unique=True, index=True, nullable=False)

class Status(Base):
    __tablename__ = 'statuses'
    status_id = Column(Integer, primary_key=True, index=True)
    status_name = Column(String, unique=True, index=True, nullable=False)

class Request(Base):
    __tablename__ = 'requests'
    request_id = Column(Integer, primary_key=True, index=True)
    request_type = Column(Integer, ForeignKey('request_types.request_type'), nullable=False)
    created_by = Column(Integer, ForeignKey('users.user_id'), nullable=False)
    assigned_to = Column(Integer, ForeignKey('users.user_id'))
    area_id = Column(Integer, ForeignKey('areas.area_id'), nullable=False)
    description = Column(String, nullable=False)
    status_id = Column(Integer, ForeignKey('statuses.status_id'), default=1, nullable=False)
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.now(timezone.utc))
    updated_at = Column(TIMESTAMP)
    deadline = Column(TIMESTAMP)
    rejection_reason = Column(String)

    creator = relationship("User", foreign_keys=[created_by])
    assignee = relationship("User", foreign_keys=[assigned_to])
    request_type_rel = relationship("RequestType")
    area_rel = relationship("Area")
    status_rel = relationship("Status")

class RequestStatusLog(Base):
    __tablename__ = 'request_status_log'
    log_id = Column(Integer, primary_key=True, index=True)
    request_id = Column(Integer, ForeignKey('requests.request_id'))
    old_status_id = Column(Integer, ForeignKey('statuses.status_id'))
    new_status_id = Column(Integer, ForeignKey('statuses.status_id'))
    changed_at = Column(String, nullable=False, default=datetime.now(timezone.utc))
    changed_by = Column(Integer, ForeignKey('users.user_id'))

    request_rel = relationship("Request")

Base.metadata.create_all(bind=engine)

# Models

class UserModel(BaseModel):
    user_id: int
    username: str
    surname: Optional[str]
    name: Optional[str]
    spec_id: Optional[int]
    fcm_token: Optional[str]
    role_id: int
    shift_id: Optional[int]

    class Config:
        orm_mode = True

class StatusModel(BaseModel):
    status_id: int
    status_name: str

    class Config:
        orm_mode = True

class LoginRequest(BaseModel):
    username: str
    password: str
    fcm_token: Optional[str] = None

class LoginResponse(BaseModel):
    user_id: int
    role_id: int

class RegisterRequest(BaseModel):
    username: str
    password: str
    role_id: int
    spec_id: Optional[int] = None

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
    deadline: Optional[datetime]
    rejection_reason: Optional[str]

    class Config:
        orm_mode = True
        json_encoders = {
            datetime: lambda v: v.strftime("%Y-%m-%dT%H:%M:%S")
        }

class RequestCreate(BaseModel):
    request_type: int
    user_id: int
    area_id: int
    description: str

class ApproveRequest(BaseModel):
    user_id: int
    request_id: int
    deadline: Optional[str] = None 

class DenyRequest(BaseModel):
    user_id: int
    request_id: int
    reason: str

class UpdateRequest(BaseModel):
    user_id: int
    request_id: int

class RequestTypeModel(BaseModel):
    request_type: int
    type_name: str

    class Config:
        orm_mode = True

class RoleModel(BaseModel):
    role_id: int
    role_name: str

    class Config:
        orm_mode = True

class RequestStatusLogModel(BaseModel):
    log_id: int
    request_id: int
    old_status_id: int
    new_status_id: int
    changed_at: datetime
    changed_by: int

    class Config:
        orm_mode = True
        json_encoders = {
            datetime: lambda v: v.strftime("%Y-%m-%dT%H:%M:%S")
        }

# Extra funcs

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def hash_password(password):
    return pwd_context.hash(password)

def update_request(request_id: int, new_status: int, user_id: int, db: Session, **kwargs):
    existing_request = db.query(Request).filter(Request.request_id == request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")
    
    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=new_status,
        changed_by=user_id
    )
    db.add(log_entry)

    existing_request.status_id = new_status
    existing_request.updated_at = datetime.now(timezone.utc)
    
    for key, value in kwargs.items():
        setattr(existing_request, key, value)

    db.commit()
    db.refresh(existing_request)
    db.refresh(log_entry)
    return existing_request

# Endpoints

@app.get("/")
def read_root():
    return {"message": "home page"}

@app.post("/register")
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    hashed_password = hash_password(request.password)
    user = User(username=request.username, password_hash=hashed_password, role_id=request.role_id, spec_id=request.spec_id)
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"user_id": user.user_id}

@app.post("/login", response_model=LoginResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == request.username).first()
    if user is None or not verify_password(request.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Invalid username or password")
    
    if request.fcm_token:
        user.fcm_token = request.fcm_token
        db.commit()
    
    return LoginResponse(user_id=user.user_id, role_id=user.role_id)

@app.post("/create-request", response_model=dict)
def create_request(request: RequestCreate, db: Session = Depends(get_db)):
    new_request = Request(
        request_type=request.request_type,
        created_by=request.user_id,
        area_id=request.area_id,
        description=request.description
    )
    db.add(new_request)
    db.commit()
    db.refresh(new_request)
    return {"message": "Request created successfully", "request_id": new_request.request_id}

@app.post("/master-approve", response_model=dict)
def approve_request(request: ApproveRequest, db: Session = Depends(get_db)):
    existing_request = update_request(
        request.request_id,
        new_status=2,
        user_id=request.user_id,
        db=db
    )
    creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
    if creator_user is None or not creator_user.fcm_token:
        raise HTTPException(status_code=404, detail="Users's FCM token not found")
    try:
        send_push(
            token=creator_user.fcm_token,
            title="Request Approved",
            body=f"Your request (ID: {existing_request.request_id}) has been approved."
        )
    except Exception as e:
        # raise HTTPException(status_code=500, detail=f"Push notification failed: {str(e)}")
        pass
    return {"message": "Request approved successfully", "request_id": existing_request.request_id}


@app.post("/master-deny", response_model=dict)
def deny_request(request: DenyRequest, db: Session = Depends(get_db)):
    existing_request = update_request(
        request.request_id,
        new_status=3,
        user_id=request.user_id,
        db=db,
        rejection_reason=request.reason
    )
    creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
    if creator_user is None or not creator_user.fcm_token:
        raise HTTPException(status_code=404, detail="Users's FCM token not found")
    try:
        send_push(
            token=creator_user.fcm_token,
            title="Request Denied",
            body=f"Your request (ID: {existing_request.request_id}) has been denied."
        )
    except Exception as e:
        # raise HTTPException(status_code=500, detail=f"Push notification failed: {str(e)}")
        pass
    return {"message": "Request denied successfully", "request_id": existing_request.request_id}

@app.post("/take-on-work", response_model=dict)
def take_request(request: UpdateRequest, db: Session = Depends(get_db)):
    existing_request = update_request(
        request.request_id,
        new_status=4,
        user_id=request.user_id,
        db=db,
        assigned_to=request.user_id
    )
    creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
    if creator_user is None or not creator_user.fcm_token:
        raise HTTPException(status_code=404, detail="Users's FCM token not found")
    try:
        send_push(
            token=creator_user.fcm_token,
            title="Request is in work",
            body=f"Your request (ID: {existing_request.request_id}) has been taken to work."
        )
    except Exception as e:
        # raise HTTPException(status_code=500, detail=f"Push notification failed: {str(e)}")
        pass
    return {"message": "Request accepted into work successfully", "request_id": existing_request.request_id}

@app.post("/executor-cancel", response_model=dict)
def cancel_request(request: DenyRequest, db: Session = Depends(get_db)):
    existing_request = update_request(
        request.request_id,
        new_status=2,
        user_id=request.user_id,
        db=db,
        assigned_to=None,
        rejection_reason=request.reason
    )
    creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
    if creator_user is None or not creator_user.fcm_token:
        raise HTTPException(status_code=404, detail="Users's FCM token not found")
    try:
        send_push(
            token=creator_user.fcm_token,
            title="Request has been canceled",
            body=f"Your request (ID: {existing_request.request_id}) has been canceled by executor."
        )
    except Exception as e:
        # raise HTTPException(status_code=500, detail=f"Push notification failed: {str(e)}")
        pass
    return {"message": "Request canceled successfully", "request_id": existing_request.request_id}

@app.post("/executor-complete", response_model=dict)
def complete_request(request: UpdateRequest, db: Session = Depends(get_db)):
    existing_request = update_request(request.request_id, 5, request.user_id, db)
    creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
    if creator_user is None or not creator_user.fcm_token:
        raise HTTPException(status_code=404, detail="Users's FCM token not found")
    try:
        send_push(
            token=creator_user.fcm_token,
            title="Request has been completed",
            body=f"Your request (ID: {existing_request.request_id}) has been completed by executor."
        )
    except Exception as e:
        # raise HTTPException(status_code=500, detail=f"Push notification failed: {str(e)}")
        pass
    return {"message": "Request completed successfully", "request_id": request.request_id}

@app.post("/requestor-confirm", response_model=dict)
def confirm_request(request: UpdateRequest, db: Session = Depends(get_db)):
    existing_request = update_request(request.request_id, 6, request.user_id, db)
    executor_user = db.query(User).filter(User.user_id == existing_request.assigned_to).first()
    if executor_user is None or not executor_user.fcm_token:
        raise HTTPException(status_code=404, detail="Users's FCM token not found")
    try:
        send_push(
            token=executor_user.fcm_token,
            title="Request has been confirmed",
            body=f"Your work (ID: {existing_request.request_id}) has been confirmed by requestor."
        )
    except Exception as e:
        # raise HTTPException(status_code=500, detail=f"Push notification failed: {str(e)}")
        pass
    return {"message": "Request confirmed successfully", "request_id": request.request_id}

@app.post("/requestor-deny", response_model=dict)
def deny_request(request: DenyRequest, db: Session = Depends(get_db)):
    existing_request = update_request(
        request.request_id,
        new_status=4,
        user_id=request.user_id,
        db=db,
        rejection_reason=request.reason
    )
    executor_user = db.query(User).filter(User.user_id == existing_request.assigned_to).first()
    if executor_user is None or not executor_user.fcm_token:
        raise HTTPException(status_code=404, detail="Users's FCM token not found")
    try:
        send_push(
            token=executor_user.fcm_token,
            title="Request has been declined",
            body=f"Your work (ID: {existing_request.request_id}) has been declined by requestor."
        )
    except Exception as e:
        # raise HTTPException(status_code=500, detail=f"Push notification failed: {str(e)}")
        pass
    return {"message": "Request denied successfully", "request_id": existing_request.request_id}

@app.get("/requests", response_model=List[RequestModel])
def get_requests(db: Session = Depends(get_db)):
    requests = db.query(Request).all()
    return requests

@app.get("/request-types", response_model=List[RequestTypeModel])
def get_request_types(db: Session = Depends(get_db)):
    request_types = db.query(RequestType).all()
    return request_types

@app.get("/roles", response_model=List[RoleModel])
def get_roles(db: Session = Depends(get_db)):
    roles = db.query(Role).all()
    return roles

@app.get("/users", response_model=List[UserModel])
def get_users(db: Session = Depends(get_db)):
    users = db.query(User).all()
    return users

@app.get("/statuses", response_model=List[StatusModel])
def get_statuses(db: Session = Depends(get_db)):
    statuses = db.query(Status).all()
    return statuses

@app.get("/under-master-approval", response_model=List[RequestModel])
def get_under_master_approval_requests(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.user_id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    spec_id = user.spec_id
    if spec_id is None:
        raise HTTPException(status_code=400, detail="User does not have a spec_id")
    
    requests = db.query(Request).filter(
        Request.status_id == 1,
        Request.request_type == spec_id
    ).all()
    
    return requests

@app.get("/under-master-monitor", response_model=List[RequestModel])
def get_under_master_approval_requests(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.user_id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    spec_id = user.spec_id
    if spec_id is None:
        raise HTTPException(status_code=400, detail="User does not have a spec_id")
    
    requests = db.query(Request).filter(
        Request.status_id != 1,
        Request.request_type == spec_id
    ).all()

    return requests

@app.get("/in-progress", response_model=List[RequestModel])
def get_in_progress_requests(user_id: int, db: Session = Depends(get_db)):
    requests = db.query(Request).filter(
        Request.status_id.in_([1, 2, 4, 5]), 
        Request.created_by == user_id
    ).all()
    return requests

@app.get("/denied", response_model=List[RequestModel])
def get_denied_requests(user_id: int, db: Session = Depends(get_db)):
    requests = db.query(Request).filter(Request.status_id == 3, Request.created_by == user_id).all()
    return requests

@app.get("/under-requestor-approval", response_model=List[RequestModel])
def get_under_requestor_approval_requests(user_id: int, db: Session = Depends(get_db)):
    requests = db.query(Request).filter(Request.status_id == 5, Request.created_by == user_id).all()
    return requests

@app.get("/completed", response_model=List[RequestModel])
def get_completed_requests(user_id: int, db: Session = Depends(get_db)):
    requests = db.query(Request).filter(Request.status_id == 6, Request.created_by == user_id).all()
    return requests

@app.get("/my-tasks", response_model=List[RequestModel])
def get_my_tasks(user_id: int, db: Session = Depends(get_db)):
    tasks = db.query(Request).filter(Request.assigned_to == user_id).all()
    return tasks

@app.get("/unassigned", response_model=List[RequestModel])
def get_unassigned(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.user_id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    spec_id = user.spec_id
    if spec_id is None:
        raise HTTPException(status_code=400, detail="User does not have a spec_id")
    
    tasks = db.query(Request).filter(
        Request.assigned_to.is_(None),
        Request.request_type == spec_id
    ).all()
    
    return tasks

@app.get("/request-status-log", response_model=List[RequestStatusLogModel])
def get_request_status_log(db: Session = Depends(get_db)):
    logs = db.query(RequestStatusLog).all()
    return logs


# Firebase push

cred = credentials.Certificate("accKey.json")
initialize_app(cred)

PROJECT_ID = 'horizons-champ'
BASE_URL = 'https://fcm.googleapis.com'
FCM_ENDPOINT = 'v1/projects/' + PROJECT_ID + '/messages:send'
FCM_URL = BASE_URL + '/' + FCM_ENDPOINT
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

def send_push(fcmToken: str, title="title", body="body"):
    credentials = service_account.Credentials.from_service_account_file(
        'accKey.json', scopes=SCOPES)
    request = google.auth.transport.requests.Request()
    credentials.refresh(request)
    googleToken = credentials.token
    headers = {
        'Authorization': 'Bearer ' + googleToken,
        'Content-Type': 'application/json; UTF-8',
    }
    message = {
        "message": {
            "token": fcmToken,
            "notification": {
                "title": title,
                "body": body
            }
        }
    }
    message_json = json.dumps(message)
    resp = requests.post(FCM_URL, data=message_json, headers=headers)
    if resp.status_code == 200:
        return {'message': 'Message sent to Firebase for delivery', 'response': resp.text}
    else:
        raise HTTPException(status_code=resp.status_code, detail=resp.text)