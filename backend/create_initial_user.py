import os
from sqlalchemy.orm import Session
from backend.app import get_db, User
from backend.app import hash_password
from fastapi import HTTPException
from sqlalchemy.exc import IntegrityError

def create_initial_user():
    # Open a DB session
    db: Session = next(get_db())
    
    # Define user details for initial setup
    initial_user_data = {
        "username": os.getenv("INITIAL_USER_USERNAME"),
        "password": os.getenv("INITIAL_USER_PASSWORD"),
        "surname": "Admin",
        "name": "Admin",
        "middle_name": "Admin",
        "hire_date": "2024-01-01",
        "phone_number": "+123456789",
        "birth_date": "1990-01-01",
        "email": "admin@example.com",
        "role_id": 1,
        "specialization": "Admin",
        "request_type": 1
    }

    try:
        # Hash the password using the app's password hashing function
        hashed_password = hash_password(initial_user_data["password"])

        # Create the user instance
        new_user = User(
            username=initial_user_data["username"],
            password_hash=hashed_password,
            surname=initial_user_data["surname"],
            name=initial_user_data["name"],
            middle_name=initial_user_data["middle_name"],
            hire_date=initial_user_data["hire_date"],
            phone_number=initial_user_data["phone_number"],
            birth_date=initial_user_data["birth_date"],
            email=initial_user_data["email"],
            role_id=initial_user_data["role_id"],
            specialization=initial_user_data["specialization"],
            request_type=initial_user_data["request_type"]
        )

        # Add and commit the user
        db.add(new_user)
        db.commit()
        db.refresh(new_user)

        print(f"User '{new_user.username}' created successfully.")
    
    except IntegrityError as e:
        db.rollback()  # Rollback the transaction on error
        detail = str(e.orig)
        raise HTTPException(status_code=400, detail=detail)

if __name__ == "__main__":
    create_initial_user()
