from fastapi import FastAPI, HTTPException, Depends
from typing import List
from sqlalchemy import func
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.exc import IntegrityError
from passlib.context import CryptContext
from starlette.responses import JSONResponse
from datetime import datetime, timezone
from backend.utils import send_push
from backend.schemas import *
from backend.models import engine, Request, RequestType, Role, User, Status, RequestStatusLog
from traceback import format_exception


app = FastAPI()

@app.exception_handler(Exception)
async def exception_handler(request: Request, exc: Exception):
    error_response = {
        "message": str(exc),
        "status_code": 500,
        "error": {
            "type": type(exc).__name__,
            "message": str(exc),
            "traceback": format_exception(type(exc), exc, exc.__traceback__)
        }
    }
    return JSONResponse(error_response, status_code=500)

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    error_response = {
        "message": exc.detail,
        "status_code": exc.status_code,
        "error": {
            "type": type(exc).__name__,
            "message": exc.detail,
            "traceback": format_exception(type(exc), exc, exc.__traceback__)
        }
    }
    return JSONResponse(error_response, status_code=exc.status_code)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

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

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password):
    return pwd_context.hash(password)

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


def get_user_by_username(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def extract_unique_device_id(fcm_token: str) -> str:
    return fcm_token.split(":")[0] 


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


@app.post("/login", response_model=LoginResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    try:
        user = get_user_by_username(db, request.username)
        
        if not user or not verify_password(request.password, user.password_hash):
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        if request.fcm_token:
            print(request.fcm_token)
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


def remove_fcm_token(user: User, old_fcm: str, db: Session):
    if user.fcm_token and old_fcm in user.fcm_token:
        user.fcm_token = [token for token in user.fcm_token if token != old_fcm]
        db.commit()
        db.refresh(user)


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

        # Find users with matching request_type and role_id=2
        matching_users = db.query(User).filter(
            User.request_type == request.request_type,
            User.role_id == 2
        ).all()

        # Extract FCM tokens and send push notifications
        for user in matching_users:
            if user.fcm_token:
                resps = send_push(
                    tokens=user.fcm_token,
                    title="Новый запрос",
                    body=f"Поступил новый запрос (№ {new_request.request_id})"
                )
                for resp in resps:
                    print(f"Token: {resp['token']}, Status: {resp['status']}, Response/Error: {resp.get('response') or resp.get('error')}")

        return {"message": "Request created successfully", "request_id": new_request.request_id}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


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
        
        # Send push notification to the request creator
        creator_user = db.query(User).filter(User.user_id == existing_request.created_by).first()
        resps = send_push(
            tokens=creator_user.fcm_token,
            title="Запрос согласован",
            body=f"Ваш запрос (№ {existing_request.request_id}) был согласован мастером"
        )
        for resp in resps:
            print(f"Token: {resp['token']}, Status: {resp['status']}, Response/Error: {resp.get('response') or resp.get('error')}")

        # Send push notification to all users with the same request_type and role_id=1
        executor_users = db.query(User).filter(
            User.request_type == existing_request.request_type,
            User.role_id == 1
        ).all()

        resps = send_push(
            tokens=[user.fcm_token for user in executor_users if user.fcm_token],
            title="Запрос ожидает исполнения",
            body=f"Запрос (№ {existing_request.request_id}) был согласован и ожидает выполнения"
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
            body=f"Ваш запрос (№ {existing_request.request_id}) был отклонен мастером"
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
            body=f"Ваш запрос (№ {existing_request.request_id}) был взят в работу"
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
            body=f"Ваш запрос (№ {existing_request.request_id}) был возвращен исполнителем"
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
            body=f"Ваш запрос (№ {existing_request.request_id}) был исполнен и ожидает проверки"
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
            body=f"Ваша работа (№ {existing_request.request_id}) была принята заявителем"
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
            body=f"Ваша работа (№ {existing_request.request_id}) была отправлена на доработку заявителем"
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