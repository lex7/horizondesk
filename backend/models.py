from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey, event, func
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import relationship
from sqlalchemy.types import TIMESTAMP
from datetime import datetime, timezone
import os
from dotenv import load_dotenv


load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)

Base = declarative_base()

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