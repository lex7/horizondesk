from pydantic import BaseModel, Field

class MessageRequest(BaseModel):
    deviceType: int
    fcmToken: str

class Issue(BaseModel):
    subject: str = Field(..., description="The subject of the issue")
    message: str = Field(..., description="The message describing the issue")