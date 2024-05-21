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
    deadline: str = Field(..., description="Deadline date")
    completed: str = Field(..., description="Timestamp of completion")

class IssueUpdate(BaseModel):
    id: str = Field(..., description="Issue id")

class IssueComplete(BaseModel):
    id: str = Field(..., description="Issue id")
    completed: str = Field(..., description="Completed or declined date")

class IssueAccept(BaseModel):
    id: str = Field(..., description="Issue id")
    deadline: str = Field(..., description="Deadline date")
