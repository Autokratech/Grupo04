from pydantic import BaseModel
from uuid import UUID

# -- Requests
class DashboardCreate(BaseModel):
    user_id : UUID
    dashboard_theme: str | None = "default"
    dashboard_language: str | None = "spanish"

class DashboardUpdateTheme(BaseModel):
    dashboard_theme: str


# -- Responses
class DashboardResponse(BaseModel):
    dashboard_id: UUID
    dashboard_theme: str 
    dashboard_language: str 
