import firebase_admin
from firebase_admin import credentials
from google.oauth2 import service_account
import google.auth.transport.requests
import requests
import json
from fastapi import HTTPException

cred = credentials.Certificate("accKey.json")
firebase_admin.initialize_app(cred)

PROJECT_ID = 'horizons-champ'
BASE_URL = 'https://fcm.googleapis.com'
FCM_ENDPOINT = 'v1/projects/' + PROJECT_ID + '/messages:send'
FCM_URL = BASE_URL + '/' + FCM_ENDPOINT
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

def send_message(fcmToken: str, deviceType: int):
    """Retrieve a valid access token that can be used to authorize requests.
    :return: Access token.
    """
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
                "title": "Breaking News",
                "body": "New news story available."
            },
            "data": {
                "story_id": "story_12345"
            }
        }
    }
    
    message_json = json.dumps(message)
    resp = requests.post(FCM_URL, data=message_json, headers=headers)
    if resp.status_code == 200:
        return {'message': 'Message sent to Firebase for delivery', 'response': resp.text}
    else:
        raise HTTPException(status_code=resp.status_code, detail=resp.text)
