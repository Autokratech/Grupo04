from pydantic import BaseModel

class LinuxAgentResponse(BaseModel):
    count: int
    items: list[dict]