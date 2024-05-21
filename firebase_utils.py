import firebase_admin
from firebase_admin import credentials
from google.oauth2 import service_account
import google.auth.transport.requests
import requests
import json
from fastapi import HTTPException
import os
from datetime import datetime
from models import Issue
import random
import string

cred = credentials.Certificate("accKey.json")
firebase_admin.initialize_app(cred)

PROJECT_ID = 'horizons-champ'
BASE_URL = 'https://fcm.googleapis.com'
FCM_ENDPOINT = 'v1/projects/' + PROJECT_ID + '/messages:send'
FCM_URL = BASE_URL + '/' + FCM_ENDPOINT
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

def send_push(fcmToken: str, title="title", body="body"):
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

    send_push(fcmToken, "New login", f"user {id} logged in")

    return {'message': 'Token stored in DB'}


def generate_random_id(length=10):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))


def save_issue(issue_data: Issue):
    if os.path.exists("issues.json"):
        with open("issues.json", "r") as file:
            existing_data = json.load(file)
            if not isinstance(existing_data, list):
                existing_data = []
    else:
        existing_data = []

    if not issue_data.id:
        issue_data.id = generate_random_id()
    if not issue_data.status:
        issue_data.status = "new"

    print(issue_data)
    existing_data.append(issue_data.dict())

    with open("issues.json", "w") as file:
        json.dump(existing_data, file, ensure_ascii=False, indent=4)

    issue_id = issue_data.id
    try:
        send_push_by_id("2", "New issue reported", f"Issue ID: {issue_id}")
    except Exception as e:
        print(e)

    return {'message': 'Issue stored in DB'}


def send_push_by_id(id: str, title="title", body="body"):
    try:
        with open("tokens.json", "r") as file:
            tokens = json.load(file)
    except FileNotFoundError:
        raise HTTPException(status_code=404, detail="Tokens file not found")

    fcmToken = None
    for token in tokens:
        if token.get("id") == id:
            fcmToken = token.get("fcmToken")
            break

    if fcmToken:
        send_push(fcmToken, title, body)
    else:
        raise HTTPException(status_code=404, detail=f"FCM token not found for ID {id}")
    

def update_status(issue_id: str, new_status: str, date: str):
    if os.path.exists("issues.json"):
        with open("issues.json", "r") as file:
            issues = json.load(file)
    else:
        raise HTTPException(status_code=404, detail="Issues file not found")

    issue_found = False
    for issue in issues:
        if issue["id"] == issue_id:
            issue["status"] = new_status
            issue_found = True
            break

    if date:
        for issue in issues:
            if issue["id"] == issue_id:
                issue["deadline"] = date
                break
    elif new_status == "done":
        for issue in issues:
            if issue["id"] == issue_id:
                issue["completed"] = datetime.now().strftime("%d-%m-%Y")
                break

    if not issue_found:
        raise HTTPException(status_code=404, detail=f"Issue with ID {issue_id} not found")

    with open("issues.json", "w", encoding='utf-8') as file:
        json.dump(issues, file, ensure_ascii=False, indent=4)

    return {'message': f'Issue status updated to {new_status}'}