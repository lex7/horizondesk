from fastapi import FastAPI
from models import UserData, Issue
from firebase_utils import store_token, save_issue
import json

app = FastAPI()

@app.post("/assign-fcm")
def assign_fcm_endpoint(request: UserData):
    return store_token(request.id, request.fcmToken)

@app.post("/send-issue")
async def send_issue(issue_data: Issue):
    try:
        return save_issue(issue_data)
    except Exception as e:
        print(e)

@app.get("/get-issues")
async def get_issues():
    with open("issues.json", "r") as file:
        data = json.load(file)
    return data
