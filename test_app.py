from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from backend.app import app, get_db
from backend.models import Base
import os
import pytest


DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create a fixture for the database session

@pytest.fixture(scope="function")
def db_session():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)


def test_root(db_session: Session) -> None:
    client = TestClient(app)
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "ok"}


def test_get_requests(db_session: Session) -> None:
    client = TestClient(app)
    response = client.get("/requests")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_login(db_session: Session) -> None:
    client = TestClient(app)
    response = client.post("/login", json={"username": "alex", "password": "1234"})
    assert response.status_code == 200
    assert isinstance(response.json(), dict)
    assert "access_token" in response.json()
    assert "token_type" in response.json()
