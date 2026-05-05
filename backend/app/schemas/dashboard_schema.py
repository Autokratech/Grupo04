from pydantic import BaseModel
from typing import Optional
from uuid import UUID

# -- Requests
class DashboardCreate(BaseModel):
    user_id : int
    dashboard_theme: str | None = "default"

class DashboardUpdateTheme(BaseModel):
    dashboard_theme: str


# -- Responses
class DashboardResponse(BaseModel):
    dashboard_id: UUID
    user_id: int
    dashboard_theme: str | None = None
