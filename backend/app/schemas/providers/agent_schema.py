from pydantic import BaseModel
from typing import Any


class MetricItem(BaseModel):
    agent_id: str
    agent_data: dict[str, Any]
    created_at: str


class AgentResponse(BaseModel):
    count: int
    items: list[MetricItem]
