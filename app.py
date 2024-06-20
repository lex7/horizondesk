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

@app.get("/")
def read_root():
    return {"message": "Yo"}

class User(Base):
    __tablename__ = 'users'
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    position_id = Column(Integer, ForeignKey('positions.position_id'))

    position = relationship("Position", back_populates="users")

class Position(Base):
    __tablename__ = 'positions'
    position_id = Column(Integer, primary_key=True, index=True)
    position_name = Column(String, unique=True, index=True, nullable=False)
    
    users = relationship("User", back_populates="position")

class RequestType(Base):
    __tablename__ = 'request_types'
    type_id = Column(Integer, primary_key=True, index=True)
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
    request_type = Column(Integer, ForeignKey('request_types.type_id'), nullable=False)
    created_by = Column(Integer, ForeignKey('users.user_id'), nullable=False)
    assigned_to = Column(Integer, ForeignKey('users.user_id'))
    area_id = Column(Integer, ForeignKey('areas.area_id'), nullable=False)
    description = Column(String, nullable=False)
    status_id = Column(Integer, ForeignKey('statuses.status_id'), default=1, nullable=False)
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)
    updated_at = Column(TIMESTAMP)
    deadline = Column(TIMESTAMP)

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

class LoginResponse(BaseModel):
    user_id: int
    position_id: int

class RegisterRequest(BaseModel):
    username: str
    password: str
    position_id: int

class RequestCreate(BaseModel):
    request_type: int
    user_id: int
    area_id: int
    description: str

class ApproveRequest(BaseModel):
    user_id: int
    request_id: int
    assign_to: int
    deadline: datetime = None

class RejectRequest(BaseModel):
    user_id: int
    request_id: int

class CompleteRequest(BaseModel):
    user_id: int
    request_id: int

class ConfirmRequest(BaseModel):
    user_id: int
    request_id: int

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
    user = User(username=request.username, password_hash=hashed_password, position_id=request.position_id)
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"user_id": user.user_id}

@app.post("/login", response_model=LoginResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == request.username).first()
    if user is None or not verify_password(request.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Invalid username or password")
    
    return LoginResponse(user_id=user.user_id, position_id=user.position_id)

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
    existing_request = db.query(Request).filter(Request.request_id == request.request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")

    existing_request.assigned_to = request.assign_to
    existing_request.updated_at = datetime.now()
    if request.deadline:
        existing_request.deadline = request.deadline

    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=2,
        changed_by=request.user_id
    )
    db.add(log_entry)

    existing_request.status_id = 2

    db.commit()
    db.refresh(existing_request)
    db.refresh(log_entry)

    return {"message": "Request approved successfully", "request_id": existing_request.request_id}

@app.post("/reject-request", response_model=dict)
def reject_request(request: RejectRequest, db: Session = Depends(get_db)):
    existing_request = db.query(Request).filter(Request.request_id == request.request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")

    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=3,
        changed_by=request.user_id
    )
    db.add(log_entry)

    existing_request.status_id = 3

    db.commit()
    db.refresh(existing_request)
    db.refresh(log_entry)

    return {"message": "Request rejected successfully", "request_id": existing_request.request_id}

@app.post("/complete-request", response_model=dict)
def complete_request(request: CompleteRequest, db: Session = Depends(get_db)):
    existing_request = db.query(Request).filter(Request.request_id == request.request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")
    if existing_request.assigned_to != request.user_id:
        raise HTTPException(status_code=403, detail="Permission denied")

    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=4,
        changed_by=request.user_id
    )
    db.add(log_entry)

    existing_request.status_id = 4
    existing_request.updated_at = datetime.now()

    db.commit()
    db.refresh(existing_request)
    db.refresh(log_entry)

    return {"message": "Request completed successfully", "request_id": existing_request.request_id}

@app.post("/confirm-request", response_model=dict)
def confirm_request(request: ConfirmRequest, db: Session = Depends(get_db)):
    existing_request = db.query(Request).filter(Request.request_id == request.request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")
    if existing_request.created_by != request.user_id:
        raise HTTPException(status_code=403, detail="Permission denied")

    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=5,
        changed_by=request.user_id
    )
    db.add(log_entry)

    existing_request.status_id = 5
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
             "deadline": request.deadline} for request in requests]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=443, reload=True)
