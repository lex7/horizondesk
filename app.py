import os
from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, TIMESTAMP
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from passlib.context import CryptContext
from pydantic import BaseModel
from sqlalchemy.orm import Session
from dotenv import load_dotenv
from datetime import datetime
from typing import List, Optional

load_dotenv()

# Load environment variables from system
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

@app.get("/")
def read_root():
    return {"message": "home page"}

class User(Base):
    __tablename__ = 'users'
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    surname = Column(String)
    name = Column(String)
    specialization = Column(String)
    fcm_token = Column(String, nullable=True)
    role_id = Column(Integer, ForeignKey('roles.role_id'))
    shift_id = Column(Integer, ForeignKey('worker_shifts.shift_id'))

    role = relationship("Role", back_populates="users")
    shift = relationship("WorkerShift", back_populates="users")

class Role(Base):
    __tablename__ = 'roles'
    role_id = Column(Integer, primary_key=True, index=True)
    role_name = Column(String, unique=True, index=True, nullable=False)
    
    users = relationship("User", back_populates="role")

class WorkerShift(Base):
    __tablename__ = 'worker_shifts'
    shift_id = Column(Integer, primary_key=True, index=True)
    start_time = Column(TIMESTAMP, nullable=False)
    end_time = Column(TIMESTAMP, nullable=False)
    
    users = relationship("User", back_populates="shift")

class UserModel(BaseModel):
    user_id: int
    username: str
    surname: Optional[str]
    name: Optional[str]
    specialization: Optional[str]
    fcm_token: Optional[str]
    role_id: int
    shift_id: Optional[int]

    class Config:
        orm_mode = True

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

class StatusModel(BaseModel):
    status_id: int
    status_name: str

    class Config:
        orm_mode = True

class Request(Base):
    __tablename__ = 'requests'
    request_id = Column(Integer, primary_key=True, index=True)
    request_type = Column(Integer, ForeignKey('request_types.request_type'), nullable=False)
    created_by = Column(Integer, ForeignKey('users.user_id'), nullable=False)
    assigned_to = Column(Integer, ForeignKey('users.user_id'))
    area_id = Column(Integer, ForeignKey('areas.area_id'), nullable=False)
    description = Column(String, nullable=False)
    status_id = Column(Integer, ForeignKey('statuses.status_id'), default=1, nullable=False)
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)
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
    changed_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)
    changed_by = Column(Integer, ForeignKey('users.user_id'))

    request_rel = relationship("Request")

Base.metadata.create_all(bind=engine)

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

class RequestCreate(BaseModel):
    request_type: int
    user_id: int
    area_id: int
    description: str

class ApproveRequest(BaseModel):
    user_id: int
    request_id: int
    deadline: datetime = None

class RejectRequest(BaseModel):
    user_id: int
    request_id: int
    reason: str

class CompleteRequest(BaseModel):
    user_id: int
    request_id: int

class ConfirmRequest(BaseModel):
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

@app.post("/register")
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    hashed_password = hash_password(request.password)
    user = User(username=request.username, password_hash=hashed_password, role_id=request.role_id)
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"user_id": user.user_id}

@app.post("/login", response_model=LoginResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == request.username).first()
    if user is None or not verify_password(request.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Invalid username or password")
    
    # Update the fcm_token if provided
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

@app.post("/approve-request", response_model=dict)
def approve_request(request: ApproveRequest, db: Session = Depends(get_db)):
    # Retrieve the request to be approved
    existing_request = db.query(Request).filter(Request.request_id == request.request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")

    # Update request details
    existing_request.updated_at = datetime.now()
    if request.deadline:
        existing_request.deadline = request.deadline

    # Log status change in request_status_log
    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=2,  # Status ID for 'approved'
        changed_by=request.user_id  # Assuming the current user is making the change
    )
    db.add(log_entry)

    existing_request.status_id = 2

    db.commit()
    db.refresh(existing_request)
    db.refresh(log_entry)

    return {"message": "Request approved successfully", "request_id": existing_request.request_id}

@app.post("/reject-request", response_model=dict)
def reject_request(request: RejectRequest, db: Session = Depends(get_db)):
    # Retrieve the request to be rejected
    existing_request = db.query(Request).filter(Request.request_id == request.request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")

    # Log status change in request_status_log
    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=3,  # Status ID for 'rejected'
        changed_by=request.user_id  # Assuming the current user is making the change
    )
    db.add(log_entry)

    existing_request.status_id = 3
    existing_request.rejection_reason = request.reason  # Store the rejection reason
    existing_request.updated_at = datetime.now()

    db.commit()
    db.refresh(existing_request)
    db.refresh(log_entry)

    return {"message": "Request rejected successfully", "request_id": existing_request.request_id}

@app.post("/take-on-work", response_model=dict)
def complete_request(request: CompleteRequest, db: Session = Depends(get_db)):
    # Retrieve the request to be marked as completed
    existing_request = db.query(Request).filter(Request.request_id == request.request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")
    
    # Log status change in request_status_log
    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=4,  
        changed_by=request.user_id
    )
    db.add(log_entry)

    existing_request.assigned_to = request.user_id
    existing_request.status_id = 4
    existing_request.updated_at = datetime.now()

    db.commit()
    db.refresh(existing_request)
    db.refresh(log_entry)

    return {"message": "Request accepted into work successfully", "request_id": existing_request.request_id}

@app.post("/complete-request", response_model=dict)
def complete_request(request: CompleteRequest, db: Session = Depends(get_db)):
    # Retrieve the request to be marked as completed
    existing_request = db.query(Request).filter(Request.request_id == request.request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")

    # Log status change in request_status_log
    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=5,  # Status ID for 'completed'
        changed_by=request.user_id  # Assuming the current user is making the change
    )
    db.add(log_entry)

    existing_request.status_id = 5
    existing_request.updated_at = datetime.now()

    db.commit()
    db.refresh(existing_request)
    db.refresh(log_entry)

    return {"message": "Request marked as completed successfully", "request_id": existing_request.request_id}

@app.post("/confirm-request", response_model=dict)
def confirm_request(request: ConfirmRequest, db: Session = Depends(get_db)):
    # Retrieve the request to be confirmed
    existing_request = db.query(Request).filter(Request.request_id == request.request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")

    # Log status change in request_status_log
    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=6,  # Status ID for 'confirmed'
        changed_by=request.user_id  # Assuming the current user is making the change
    )
    db.add(log_entry)

    existing_request.status_id = 6
    existing_request.updated_at = datetime.now()

    db.commit()
    db.refresh(existing_request)
    db.refresh(log_entry)

    return {"message": "Request confirmed successfully", "request_id": existing_request.request_id}

@app.get("/requests")
def get_requests(db: Session = Depends(get_db)):
    requests = db.query(Request).all()
    return [{"request_id": request.request_id,
             "request_type": request.request_type,
             "created_by": request.created_by,
             "assigned_to": request.assigned_to,
             "area_id": request.area_id,
             "description": request.description,
             "status_id": request.status_id,
             "created_at": request.created_at,
             "updated_at": request.updated_at,
             "deadline": request.deadline,
             "rejection_reason": request.rejection_reason} for request in requests]

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

@app.get("/under-master-approval", response_model=List[dict])
def get_under_master_approval_requests(db: Session = Depends(get_db)):
    requests = db.query(Request).filter(Request.status_id == 1).all()
    return [{"request_id": request.request_id,
             "request_type": request.request_type,
             "created_by": request.created_by,
             "assigned_to": request.assigned_to,
             "area_id": request.area_id,
             "description": request.description,
             "status_id": request.status_id,
             "created_at": request.created_at,
             "updated_at": request.updated_at,
             "deadline": request.deadline,
             "rejection_reason": request.rejection_reason} for request in requests]

@app.get("/in-progress", response_model=List[dict])
def get_in_progress_requests(user_id: int, db: Session = Depends(get_db)):
    requests = db.query(Request).filter(
        Request.status_id.in_([1, 2, 4, 5]), 
        Request.created_by == user_id
    ).all()
    return [
        {
            "request_id": request.request_id,
            "request_type": request.request_type,
            "created_by": request.created_by,
            "assigned_to": request.assigned_to,
            "area_id": request.area_id,
            "description": request.description,
            "status_id": request.status_id,
            "created_at": request.created_at,
            "updated_at": request.updated_at,
            "deadline": request.deadline,
            "rejection_reason": request.rejection_reason
        }
        for request in requests
    ]

@app.get("/denied", response_model=List[dict])
def get_denied_requests(user_id: int, db: Session = Depends(get_db)):
    requests = db.query(Request).filter(Request.status_id == 3, Request.created_by == user_id).all()
    return [{"request_id": request.request_id,
             "request_type": request.request_type,
             "created_by": request.created_by,
             "assigned_to": request.assigned_to,
             "area_id": request.area_id,
             "description": request.description,
             "status_id": request.status_id,
             "created_at": request.created_at,
             "updated_at": request.updated_at,
             "deadline": request.deadline,
             "rejection_reason": request.rejection_reason} for request in requests]

@app.get("/under-user-approval", response_model=List[dict])
def get_under_user_approval_requests(user_id: int, db: Session = Depends(get_db)):
    requests = db.query(Request).filter(Request.status_id == 4, Request.created_by == user_id).all()
    return [{"request_id": request.request_id,
             "request_type": request.request_type,
             "created_by": request.created_by,
             "assigned_to": request.assigned_to,
             "area_id": request.area_id,
             "description": request.description,
             "status_id": request.status_id,
             "created_at": request.created_at,
             "updated_at": request.updated_at,
             "deadline": request.deadline,
             "rejection_reason": request.rejection_reason} for request in requests]

@app.get("/completed", response_model=List[dict])
def get_completed_requests(user_id: int, db: Session = Depends(get_db)):
    requests = db.query(Request).filter(Request.status_id == 5, Request.created_by == user_id).all()
    return [{"request_id": request.request_id,
             "request_type": request.request_type,
             "created_by": request.created_by,
             "assigned_to": request.assigned_to,
             "area_id": request.area_id,
             "description": request.description,
             "status_id": request.status_id,
             "created_at": request.created_at,
             "updated_at": request.updated_at,
             "deadline": request.deadline,
             "rejection_reason": request.rejection_reason} for request in requests]

@app.get("/my-tasks")
def get_my_tasks(user_id: int, db: Session = Depends(get_db)):
    tasks = db.query(Request).filter(Request.assigned_to == user_id).all()
    return [{"request_id": task.request_id,
             "request_type": task.request_type,
             "created_by": task.created_by,
             "assigned_to": task.assigned_to,
             "area_id": task.area_id,
             "description": task.description,
             "status_id": task.status_id,
             "created_at": task.created_at,
             "updated_at": task.updated_at,
             "deadline": task.deadline,
             "rejection_reason": task.rejection_reason} for task in tasks]

@app.get("/unassigned")
def get_unassigned(db: Session = Depends(get_db)):
    tasks = db.query(Request).filter(Request.assigned_to.is_(None)).all()
    return [{"request_id": task.request_id,
             "request_type": task.request_type,
             "created_by": task.created_by,
             "assigned_to": task.assigned_to,
             "area_id": task.area_id,
             "description": task.description,
             "status_id": task.status_id,
             "created_at": task.created_at,
             "updated_at": task.updated_at,
             "deadline": task.deadline,
             "rejection_reason": task.rejection_reason} for task in tasks]