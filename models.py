from pydantic import BaseModel, Field

class UserData(BaseModel):
    id: str
    fcmToken: str

class Issue(BaseModel):
    id: str = Field(..., description="Issue id")
    subject: str = Field(..., description="The subject of the issue")
    message: str = Field(..., description="The message describing the issue")
    region: str = Field(..., description="The area where issue happened")
    status: str = Field(..., description="Status of issue progress")
    created: str = Field(..., description="Timestamp of creation")
    completed: str = Field(..., description="Timestamp of completion")