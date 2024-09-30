import os
from firebase_admin import credentials, initialize_app
from google.oauth2 import service_account
import google.auth.transport.requests
import requests
import json

if not os.path.exists("accKey.json"):
    print("accKey.json file is not found, skipping FCM setup")
else:
    cred = credentials.Certificate("accKey.json")
    initialize_app(cred)

PROJECT_ID = 'horizons-champ'
BASE_URL = 'https://fcm.googleapis.com'
FCM_ENDPOINT = 'v1/projects/' + PROJECT_ID + '/messages:send'
FCM_URL = BASE_URL + '/' + FCM_ENDPOINT
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

def send_push(tokens: list, title="title", body="body", type_of_request="0", sound="default", badge=1000):
    
    for token in tokens:
        try:
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
                    "token": token,
                    "notification": {
                        "title": title,
                        "body": body
                    },
                    "data": {
                        "type-of-request": type_of_request
                    },
                    "apns": {
                        "headers": {
                            "apns-priority": "10"
                        },
                        "payload": {
                            "aps": {
                                "alert": {
                                    "title": title,
                                    "body": body
                                },
                                "badge": badge,
                                "sound": sound
                            }
                        }
                    }
                }
            }

            message_json = json.dumps(message)
            
            resp = requests.post(FCM_URL, data=message_json, headers=headers)
            
            if resp.status_code == 200:
                print({'message': message, 'status': 'success', 'response': resp.text})
            else:
                print({'message': message, 'status': 'failure', 'error': resp.text})
        
        except Exception as e:
            print({'message': message, 'status': 'failure', 'error': str(e)})
    
