import os
from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey, event, func, or_, literal_column
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.types import TIMESTAMP
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from sqlalchemy.dialects.postgresql import ARRAY

from passlib.context import CryptContext
from pydantic import BaseModel, Field
from dotenv import load_dotenv
from datetime import datetime, timezone, date
from typing import List, Optional
from starlette.responses import JSONResponse

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

    user_id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    surname = Column(String(50))
    name = Column(String(50))
    middle_name = Column(String(50))
    hire_date = Column(Date)
    phone_number = Column(String(15))
    birth_date = Column(Date)
    email = Column(String(100), unique=True)
    specialization = Column(String(50))
    fcm_token = Column(ARRAY(String(255)), default=[])
    role_id = Column(Integer, ForeignKey('roles.role_id'), nullable=False)
    shift_id = Column(Integer, ForeignKey('worker_shifts.shift_id'))
    tokens = Column(Integer, default=0)
    num_created = Column(Integer, default=0)
    num_completed = Column(Integer, default=0)
    last_completed = Column(Date)
    request_type = Column(Integer, ForeignKey('request_types.request_type'))

    role = relationship("Role", back_populates="users")
    shift = relationship("WorkerShift", back_populates="users",
                         primaryjoin="User.shift_id == WorkerShift.shift_id")
    request_type_rel = relationship("RequestType")


class Role(Base):
    __tablename__ = 'roles'
    role_id = Column(Integer, primary_key=True, index=True)
    role_name = Column(String, unique=True, index=True, nullable=False)
    
    users = relationship("User", back_populates="role")

class WorkerShift(Base):
    __tablename__ = 'worker_shifts'

    shift_id = Column(Integer, primary_key=True, index=True)
    shift_name = Column(String, nullable=False)

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
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    updated_at = Column(TIMESTAMP, onupdate=func.now())
    reason = Column(String)

    creator = relationship("User", foreign_keys=[created_by])
    assignee = relationship("User", foreign_keys=[assigned_to])
    request_type_rel = relationship("RequestType")
    area_rel = relationship("Area")
    status_rel = relationship("Status")

@event.listens_for(Request, 'before_update')
def receive_before_update(mapper, connection, target):
    target.updated_at = datetime.now(timezone.utc)

class RequestStatusLog(Base):
    __tablename__ = 'request_status_log'
    log_id = Column(Integer, primary_key=True, index=True)
    request_id = Column(Integer, ForeignKey('requests.request_id'))
    old_status_id = Column(Integer, ForeignKey('statuses.status_id'))
    new_status_id = Column(Integer, ForeignKey('statuses.status_id'))
    changed_at = Column(String, nullable=False)
    changed_by = Column(Integer, ForeignKey('users.user_id'))
    reason = Column(String)
    changer_name = Column(String, nullable=True)  # New field for changer's name
    action_name = Column(String, nullable=True)   # New field for action name

    request_rel = relationship("Request")

Base.metadata.create_all(bind=engine)

# Models

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
    reason: Optional[str] = None

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

def update_request(request_id: int, new_status: int, user_id: int, db: Session, action_name: str, **kwargs):
    existing_request = db.query(Request).filter(Request.request_id == request_id).first()
    if existing_request is None:
        raise HTTPException(status_code=404, detail="Request not found")

    user = db.query(User).filter(User.user_id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    changer_name = f"{user.surname} {user.name}"
    
    log_entry = RequestStatusLog(
        request_id=existing_request.request_id,
        old_status_id=existing_request.status_id,
        new_status_id=new_status,
        changed_at=datetime.now(timezone.utc),
        changed_by=user_id,
        reason=kwargs.get('reason'),
        changer_name=changer_name,  # Populate changer_name
        action_name=action_name     # Populate action_name
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


def add_fcm_token(user: User, fcm_token: str, db: Session):
    device_id = extract_unique_device_id(fcm_token)
    # Initialize fcm_token as an empty list if it is None
    if user.fcm_token is None:
        user.fcm_token = []
    # Remove existing tokens with the same device_id
    user.fcm_token = [token for token in user.fcm_token if not token.startswith(device_id)]
    # Add the new token
    user.fcm_token.append(fcm_token)
    db.commit()



def remove_fcm_token(user: User, old_fcm: str, db: Session):
    if user.fcm_token and old_fcm in user.fcm_token:
        user.fcm_token = [token for token in user.fcm_token if token != old_fcm]
        db.commit()
        db.refresh(user)


def extract_uniq_device_id(fcm_token: str) -> str:
    return fcm_token.split(":")[0] if ":" in fcm_token else fcm_token


def get_password_hash(password):
    return pwd_context.hash(password)


def get_user_by_username(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()

def get_user_by_device_id(db: Session, device_id: str):
    pattern = f"{device_id}:%"
    return db.query(User).filter(
        func.array_to_string(User.fcm_token, ',').contains(pattern)
    ).first()

def remove_device_from_other_users(db: Session, device_id: str, user_id: int):
    users = db.query(User).filter(User.user_id != user_id).all()
    for user in users:
        # Initialize fcm_token as an empty list if it is None
        if user.fcm_token is None:
            user.fcm_token = []
        # Remove tokens starting with the device_id
        user.fcm_token = [token for token in user.fcm_token if not token.startswith(device_id)]
    db.commit()
    

def extract_unique_device_id(fcm_token: str) -> str:
    return fcm_token.split(":")[0] 


# Get Endpoints

@app.get("/")
def read_root():
    return {"message": "home page"}


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
    # Find the user
    user = db.query(User).filter(User.user_id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    if user.request_type is None:
        raise HTTPException(status_code=400, detail="User does not have a request_type")

    # Query for requests where request_type matches the user's request_type
    requests = db.query(Request).filter(
        Request.status_id == 1,
        Request.request_type == user.request_type  # Ensure request_type matches user's request_type
    ).all()

    return requests


@app.get("/under-master-monitor", response_model=List[RequestModel])
def get_under_master_monitor_requests(user_id: int, db: Session = Depends(get_db)):
    # Find the user
    user = db.query(User).filter(User.user_id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    if user.request_type is None:
        raise HTTPException(status_code=400, detail="User does not have a request_type")

    # Query for requests where request_type matches the user's request_type
    requests = db.query(Request).filter(
        Request.status_id != 1,
        Request.request_type == user.request_type  # Ensure request_type matches user's request_type
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

@app.get("/executor-assigned", response_model=List[RequestModel])
def get_my_tasks(user_id: int, db: Session = Depends(get_db)):
    tasks = db.query(Request).filter(Request.assigned_to == user_id).all()
    return tasks

@app.get("/executor-unassigned", response_model=List[RequestModel])
def get_unassigned(user_id: int, db: Session = Depends(get_db)):
    # Find the user
    user = db.query(User).filter(User.user_id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    if user.request_type is None:
        raise HTTPException(status_code=400, detail="User does not have a request_type")

    # Query for unassigned requests where request_type matches the user's request_type
    tasks = db.query(Request).filter(
        Request.assigned_to.is_(None),
        Request.request_type == user.request_type,
        Request.status_id == 2
    ).all()

    return tasks

@app.get("/requests-log", response_model=List[RequestStatusLogModel])
def get_requests_log(db: Session = Depends(get_db)):
    try:
        logs = db.query(RequestStatusLog).all()
        return [RequestStatusLogModel(
            log_id=log.log_id,
            request_id=log.request_id,
            old_status_id=log.old_status_id if log.old_status_id is not None else 0,
            new_status_id=log.new_status_id,
            changed_at=log.changed_at,
            changed_by=log.changed_by,
            reason=log.reason,
            changer_name=log.changer_name,  # Pass value or None
            action_name=log.action_name     # Pass value or None
        ) for log in logs]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/request-history", response_model=List[RequestStatusLogModel])
def get_request_history(request_id: int, db: Session = Depends(get_db)):
    history = db.query(RequestStatusLog).filter(RequestStatusLog.request_id == request_id).order_by(RequestStatusLog.log_id.asc()).all()
    if not history:
        raise HTTPException(status_code=404, detail="No history found for the specified request_id")
    return history

@app.get("/my-data", response_model=UserModel)
def get_user_data(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.get("/rewards", response_model=RewardsResponse)
def get_rewards(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    rewards_data = RewardsResponse(
        tokens=user.tokens,
        num_created=user.num_created,
        num_completed=user.num_completed,
        last_completed=user.last_completed
    )

    return rewards_data


# Post endpoints

@app.post("/register")
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    try:
        hashed_password = hash_password(request.password)
        user = User(
            username=request.username,
            password_hash=hashed_password,
            surname=request.surname,
            name=request.name,
            middle_name=request.middle_name,
            hire_date=request.hire_date,
            phone_number=request.phone_number,
            birth_date=request.birth_date,
            email=request.email,
            role_id=request.role_id,
            specialization=request.specialization,
            request_type=request.request_type
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return {"message": "User successfully registered", "user_id": user.user_id}
    except IntegrityError as e:
        db.rollback()  # Rollback the transaction if there's an error
        detail = str(e.orig)  # Extracts the original error message
        raise HTTPException(status_code=400, detail=detail)
    

@app.exception_handler(IntegrityError)
async def integrity_exception_handler(request: Request, exc: IntegrityError):
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc.orig)}
    )


@app.post("/login", response_model=LoginResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    try:
        user = get_user_by_username(db, request.username)
        
        if not user or not verify_password(request.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        if request.fcm_token:
            device_id = extract_unique_device_id(request.fcm_token)
            existing_user = get_user_by_device_id(db, device_id)

            if existing_user and existing_user.user_id != user.user_id:
                remove_device_from_other_users(db, device_id, user.user_id)
            
            add_fcm_token(user, request.fcm_token, db)
        
        return LoginResponse(user_id=user.user_id, role_id=user.role_id)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/refresh-user-token")
def refresh_user_token(request: RefreshTokenRequest, db: Session = Depends(get_db)):
    try:
        user = db.query(User).filter(User.user_id == request.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        add_fcm_token(user, request.new_fcm, db)
        return {"message": "FCM token refreshed successfully"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/logout")
def logout(request: LogoutRequest, db: Session = Depends(get_db)):
    try:
        user = db.query(User).filter(User.user_id == request.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        remove_fcm_token(user, request.old_fcm, db)
        return {"message": "FCM token removed successfully"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/create-request", response_model=dict)
def create_request(request: RequestCreate, db: Session = Depends(get_db)):
    try:
        # Create a new request
        new_request = Request(
            request_type=request.request_type,
            created_by=request.user_id,
            area_id=request.area_id,
            description=request.description
        )
        db.add(new_request)
        db.commit()
        db.refresh(new_request)

        # Update creator's request count
        creator = db.query(User).filter(User.user_id == request.user_id).first()
        if creator:
            creator.num_created += 1
            db.commit()

        # Log the creation of the request
        log_entry = RequestStatusLog(
            request_id=new_request.request_id,
            old_status_id=None,
            new_status_id=new_request.status_id,
            changed_at=datetime.now(timezone.utc),
            changed_by=request.user_id,
            changer_name=f"{creator.surname} {creator.name}",
            action_name='Запрос создан'
        )
        db.add(log_entry)
        db.commit()
        db.refresh(log_entry)

        return {"message": "Request created successfully", "request_id": new_request.request_id}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



@app.post("/master-approve", response_model=dict)
def approve_request(request: UpdateRequest, db: Session = Depends(get_db)):
    try:
        existing_request = update_request(
            request.request_id,
            new_status=2,
            user_id=request.user_id,
            db=db,
            reason=request.reason,
            action_name='Согласовано мастером'
        )
        creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
        resps = send_push(
            tokens=creator_user.fcm_token,
            title="Запрос согласован",
            body=f"Ваш запрос (ID: {existing_request.request_id}) был согласован мастером."
        )
        for resp in resps:
            print(f"Token: {resp['token']}, Status: {resp['status']}, Response/Error: {resp.get('response') or resp.get('error')}")
        
        return {"message": "Request approved successfully", "request_id": existing_request.request_id}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



@app.post("/master-deny", response_model=dict)
def deny_request(request: UpdateRequest, db: Session = Depends(get_db)):
    try:
        existing_request = update_request(
            request.request_id,
            new_status=3,
            user_id=request.user_id,
            db=db,
            reason=request.reason,
            action_name='Отклонено мастером'
        )
        creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
        resps = send_push(
            tokens=creator_user.fcm_token,
            title="Запрос отклонен",
            body=f"Ваш запрос (ID: {existing_request.request_id}) был отклонен мастером."
        )
        for resp in resps:
            print(f"Token: {resp['token']}, Status: {resp['status']}, Response/Error: {resp.get('response') or resp.get('error')}")
        
        return {"message": "Request denied successfully", "request_id": existing_request.request_id}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/take-on-work", response_model=dict)
def take_request(request: UpdateRequest, db: Session = Depends(get_db)):
    try:
        existing_request = update_request(
            request.request_id,
            new_status=4,
            user_id=request.user_id,
            db=db,
            assigned_to=request.user_id,
            action_name='Взято в работу'
        )
        creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
        resps = send_push(
            tokens=creator_user.fcm_token,
            title="Запрос в работе",
            body=f"Ваш запрос (ID: {existing_request.request_id}) был взят в работу."
        )
        for resp in resps:
            print(f"Token: {resp['token']}, Status: {resp['status']}, Response/Error: {resp.get('response') or resp.get('error')}")
        
        return {"message": "Request accepted into work successfully", "request_id": existing_request.request_id}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/executor-cancel", response_model=dict)
def cancel_request(request: UpdateRequest, db: Session = Depends(get_db)):
    try:
        existing_request = update_request(
            request.request_id,
            new_status=2,
            user_id=request.user_id,
            db=db,
            assigned_to=None,
            reason=request.reason,
            action_name='Исполнитель отказался'
        )
        creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
        resps = send_push(
            tokens=creator_user.fcm_token,
            title="Запрос был отменен",
            body=f"Ваш запрос (ID: {existing_request.request_id}) был возвращен исполнителем."
        )
        for resp in resps:
            print(f"Token: {resp['token']}, Status: {resp['status']}, Response/Error: {resp.get('response') or resp.get('error')}")
        
        return {"message": "Request canceled successfully", "request_id": existing_request.request_id}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/executor-complete", response_model=dict)
def complete_request(request: UpdateRequest, db: Session = Depends(get_db)):
    try:
        existing_request = update_request(request.request_id, 5, request.user_id, db, reason=request.reason, action_name='Исполнено')
        creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
        resps = send_push(
            tokens=creator_user.fcm_token,
            title="Запрос исполнен",
            body=f"Ваш запрос (ID: {existing_request.request_id}) был исполнен и ожидает проверки."
        )
        for resp in resps:
            print(f"Token: {resp['token']}, Status: {resp['status']}, Response/Error: {resp.get('response') or resp.get('error')}")
        
        return {"message": "Request completed successfully", "request_id": request.request_id}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/requestor-confirm", response_model=dict)
def confirm_request(request: UpdateRequest, db: Session = Depends(get_db)):
    try:
        existing_request = update_request(request.request_id, 6, request.user_id, db, reason=request.reason, action_name='Принято')
        creator = db.query(User).filter(User.user_id == request.user_id).first()
        executor = db.query(User).filter(User.user_id == existing_request.assigned_to).first()
        
        if executor:
            executor.num_completed += 1
            executor.tokens += 200
            executor.last_completed = datetime.now().date()

        if creator:
            creator.tokens += 100

        resps = send_push(
            tokens=executor.fcm_token if executor else None,
            title="Работа принята",
            body=f"Ваша работа (ID: {existing_request.request_id}) была принята заявителем."
        )
        for resp in resps:
            print(f"Token: {resp['token']}, Status: {resp['status']}, Response/Error: {resp.get('response') or resp.get('error')}")
        
        db.commit()
        return {"message": "Request confirmed successfully", "request_id": request.request_id}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/requestor-deny", response_model=dict)
def deny_request(request: UpdateRequest, db: Session = Depends(get_db)):
    try:
        existing_request = update_request(
            request.request_id,
            new_status=4,
            user_id=request.user_id,
            db=db,
            reason=request.reason,
            action_name='Отправлено на доработку'
        )
        executor_user = db.query(User).filter(User.user_id == existing_request.assigned_to).first()
        resps = send_push(
            tokens=executor_user.fcm_token,
            title="Работа отклонена",
            body=f"Ваша работа (ID: {existing_request.request_id}) была отправлена на доработку заявителем."
        )
        for resp in resps:
            print(f"Token: {resp['token']}, Status: {resp['status']}, Response/Error: {resp.get('response') or resp.get('error')}")
        
        return {"message": "Request denied successfully", "request_id": existing_request.request_id}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/requestor-delete", response_model=dict)
def soft_delete_request(request: UpdateRequest, db: Session = Depends(get_db)):
    try:
        existing_request = db.query(Request).filter(Request.request_id == request.request_id, Request.created_by == request.user_id).first()

        if existing_request is None:
            raise HTTPException(status_code=404, detail="Request not found")

        update_request(request.request_id, new_status=7, user_id=request.user_id, db=db, reason=request.reason, action_name='Удалено')

        return {"message": "Request marked as deleted successfully"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



# Firebase push

from firebase_admin import credentials, initialize_app
from google.oauth2 import service_account
import google.auth.transport.requests
import requests
import json

cred = credentials.Certificate("accKey.json")
initialize_app(cred)

PROJECT_ID = 'horizons-champ'
BASE_URL = 'https://fcm.googleapis.com'
FCM_ENDPOINT = 'v1/projects/' + PROJECT_ID + '/messages:send'
FCM_URL = BASE_URL + '/' + FCM_ENDPOINT
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

def send_push(tokens: list, title="title", body="body"):
    results = []
    
    for token in tokens:
        try:
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
                    "token": token,
                    "notification": {
                        "title": title,
                        "body": body
                    }
                }
            }
            message_json = json.dumps(message)
            
            resp = requests.post(FCM_URL, data=message_json, headers=headers)
            
            if resp.status_code == 200:
                results.append({'token': token, 'status': 'success', 'response': resp.text})
            else:
                results.append({'token': token, 'status': 'failure', 'error': resp.text})
        
        except Exception as e:
            results.append({'token': token, 'status': 'failure', 'error': str(e)})
    
    return results