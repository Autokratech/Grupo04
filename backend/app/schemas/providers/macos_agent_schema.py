from pydantic import BaseModel

class MacOSAgentResponse(BaseModel):
    count: int
    items: list[dict]