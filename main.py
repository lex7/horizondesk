from fastapi import FastAPI
from models import UserData, Issue, IssueUpdate
from firebase_utils import store_token, save_issue, update_status
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
async def approve_issue(request: IssueUpdate):
    return update_status(request.id, "approved", request.date)

@app.post("/decline-issue")
async def decline_issue(request: IssueUpdate):
    return update_status(request.id, "declined")

@app.post("/inprogress")
async def inprogress(request: IssueUpdate):
    return update_status(request.id, "inprogress")

@app.post("/send-review")
async def send_review(request: IssueUpdate):
    return update_status(request.id, "review")

@app.post("/done")
async def done(request: IssueUpdate):
    return update_status(request.id, "done")