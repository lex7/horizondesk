import firebase_admin
from firebase_admin import credentials
from google.oauth2 import service_account
import google.auth.transport.requests
import requests
import json
from fastapi import HTTPException
import os
from datetime import datetime

cred = credentials.Certificate("accKey.json")
firebase_admin.initialize_app(cred)

PROJECT_ID = 'horizons-champ'
BASE_URL = 'https://fcm.googleapis.com'
FCM_ENDPOINT = 'v1/projects/' + PROJECT_ID + '/messages:send'
FCM_URL = BASE_URL + '/' + FCM_ENDPOINT
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

def send_message(fcmToken: str, title="title", body="body"):
    credentials = service_account.Credentials.from_service_account_file(
        'accKey.json', scopes=SCOPES)
    request = google.auth.transport.requests.Request()
    credentials.refresh(request)
    googleToken = credentials.token
    headers = {
        'Authorization': 'Bearer ' + googleToken,
        'Content-Type': 'application/json; UTF-8',
    }

    message = {
        "message": {
            "token": fcmToken,
            "notification": {
                "title": title,
                "body": body
            }
        }
    }
    
    message_json = json.dumps(message)
    resp = requests.post(FCM_URL, data=message_json, headers=headers)
    if resp.status_code == 200:
        return {'message': 'Message sent to Firebase for delivery', 'response': resp.text}
    else:
        raise HTTPException(status_code=resp.status_code, detail=resp.text)

def store_token(id: str, fcmToken: str):
    current_time = datetime.now().isoformat()
    
    try:
        with open("tokens.json", "r") as file:
            tokens = json.load(file)
    except FileNotFoundError:
        tokens = []

    for token in tokens:
        if token["id"] == id:
            token["fcmToken"] = fcmToken
            token["datetime"] = current_time
            break
    else:
        tokens.append({"id": id, "fcmToken": fcmToken, "datetime": current_time})

    with open("tokens.json", "w") as file:
        json.dump(tokens, file, indent=4)

    send_message(fcmToken, "New login", f"user {id} logged in")

    return {'message': 'Token stored in DB'}

def save_issue(issue_data):
    if os.path.exists("issues.json"):
        with open("issues.json", "r") as file:
            existing_data = json.load(file)
            if not isinstance(existing_data, list):
                existing_data = []
    else:
        existing_data = []

    if "id" in issue_data.dict():
        issue_id = issue_data.id
    else:
        issue_id = str(int(datetime.now().timestamp()))

    issue_data_dict = issue_data.dict()
    issue_data_dict["id"] = issue_id

    existing_data.append(issue_data_dict)

    with open("issues.json", "w") as file:
        json.dump(existing_data, file, indent=4)

    try:
        with open("tokens.json", "r") as file:
            tokens = json.load(file)
    except FileNotFoundError:
        tokens = []

    fcmToken = None
    for token in tokens:
        if token.get("id") == "2":
            fcmToken = token.get("fcmToken")
            break

    if fcmToken:
        send_message(fcmToken, "New issue reported", f"Issue ID: {issue_id}")
    else:
        raise HTTPException(status_code=404, detail="FCM token not found for ID 2")

    return {'message': 'Issue stored in DB'}
