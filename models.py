from pydantic import BaseModel

class MessageRequest(BaseModel):
    deviceType: int
    fcmToken: str
