from fastapi import FastAPI
from models import UserData, Issue, IssueUpdate, IssueAccept, IssueComplete
from firebase_utils import store_token, save_issue, update_issue
import json

app = FastAPI()

@app.post("/assign-fcm")
def assign_fcm_endpoint(request: UserData):
    return store_token(request.id, request.fcmToken)

@app.post("/send-issue")
async def send_issue(issue_data: Issue):
    return save_issue(issue_data)

@app.get("/get-issues")
async def get_issues():
    with open("issues.json", "r") as file:
        data = json.load(file)
    return data

@app.post("/approve-issue")
async def approve_issue(request: IssueAccept):
    return update_issue(request.id, "approved", request.deadline)

@app.post("/decline-issue")
async def decline_issue(request: IssueComplete):
    return update_issue(request.id, "declined", request.completed)

@app.post("/inprogress")
async def inprogress(request: IssueUpdate):
    return update_issue(request.id, "inprogress")

@app.post("/send-review")
async def send_review(request: IssueUpdate):
    return update_issue(request.id, "review")

@app.post("/done")
async def done(request: IssueComplete):
    return update_issue(request.id, "done", request.completed)