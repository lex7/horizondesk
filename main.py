from fastapi import FastAPI
from models import MessageRequest
from firebase_utils import send_message

app = FastAPI()

@app.post("/send-message")
def send_message_endpoint(request: MessageRequest):
    return send_message(request.fcmToken, request.deviceType)
