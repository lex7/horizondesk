from fastapi import FastAPI
from models import MessageRequest
from firebase_utils import send_message
import json

app = FastAPI()

@app.post("/assign-fcm")
def assign_fcm_endpoint(request: MessageRequest):
    return send_message(request.fcmToken, request.deviceType)

@app.post("/send-issues")
async def send_issues(issue_data: dict):
    # Load existing data from test_data.json
    with open("test_data.json", "r") as file:
        existing_data = json.load(file)
    
    # Generate a new ID for the issue
    new_id = str(len(existing_data) + 1)
    
    # Add the new issue data to the existing data
    existing_data[new_id] = issue_data
    
    # Write the updated data back to test_data.json
    with open("test_data.json", "w") as file:
        json.dump(existing_data, file, indent=4)
    
    return {"message": "Issue sent successfully", "issue_id": new_id}


@app.get("/get-issues")
async def get_issues():
    # Read and return all data from test_data.json
    with open("test_data.json", "r") as file:
        data = json.load(file)
    return data