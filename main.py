from fastapi import FastAPI
from models import MessageRequest, Issue
from firebase_utils import send_message
import json
import os

app = FastAPI()

@app.post("/assign-fcm")
def assign_fcm_endpoint(request: MessageRequest):
    return send_message(request.fcmToken, request.deviceType)

@app.post("/send-issue")
async def send_issue(issue_data: Issue):
    if os.path.exists("test_data.json"):
        with open("test_data.json", "r") as file:
            existing_data = json.load(file)
            
            if not isinstance(existing_data, list):
                existing_data = []
    else:
        existing_data = []

    existing_data.append(issue_data.dict())

    with open("test_data.json", "w") as file:
        json.dump(existing_data, file, indent=4)

    return 200


@app.get("/get-issues")
async def get_issues():
    with open("test_data.json", "r") as file:
        data = json.load(file)
    return data