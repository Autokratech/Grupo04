from pydantic import BaseModel

class WindowsAgentResponse(BaseModel):
    count: int
    items: list[dict]