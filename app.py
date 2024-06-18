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
    request_type = Column(Integer, ForeignKey('request_types.type_id'))
    created_by = Column(Integer, ForeignKey('users.user_id'))
    assigned_to = Column(Integer, ForeignKey('users.user_id'))
    area_id = Column(Integer, ForeignKey('areas.area_id'))
    description = Column(String, nullable=False)
    status_id = Column(Integer, ForeignKey('statuses.status_id'), default=1)
    created_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)
    updated_at = Column(TIMESTAMP, nullable=False, default=datetime.utcnow)
    deadline = Column(TIMESTAMP, nullable=False)

    creator = relationship("User", foreign_keys=[created_by])
    assignee = relationship("User", foreign_keys=[assigned_to])
    request_type_rel = relationship("RequestType")
    area_rel = relationship("Area")
    status_rel = relationship("Status")

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

@app.post("/create_request", response_model=dict)
def create_request(request: RequestCreate, db: Session = Depends(get_db)):
    new_request = Request(
        request_type=request.request_type,
        created_by=request.user_id,
        area_id=request.area_id,
        description=request.description,
        deadline=datetime.now()  # Set the current time for the deadline
    )
    db.add(new_request)
    db.commit()
    db.refresh(new_request)
    return {"message": "Request created successfully", "request_id": new_request.request_id}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=443, reload=True)
