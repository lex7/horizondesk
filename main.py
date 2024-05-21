from fastapi import FastAPI
from models import MessageRequest, Issue
from firebase_utils import send_message
import json

app = FastAPI()

@app.post("/assign-fcm")
def assign_fcm_endpoint(request: MessageRequest):
    return send_message(request.fcmToken, request.deviceType)

@app.post("/send-issue")
async def send_issue(issue_data: Issue):
    if os.path.exists("test_data.json"):
        with open("test_data.json", "r") as file:
            existing_data = json.load(file)
    else:
        existing_data = {}

    new_id = str(len(existing_data) + 1)
    
    existing_data[new_id] = issue_data.dict()
    
    with open("test_data.json", "w") as file:
        json.dump(existing_data, file, indent=4)
    
    return {"message": "Issue sent successfully", "issue_id": new_id}


@app.get("/get-issues")
async def get_issues():
    # Read and return all data from test_data.json
    with open("test_data.json", "r") as file:
        data = json.load(file)
    return data