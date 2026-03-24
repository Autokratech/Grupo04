from pydantic import BaseModel
from typing import Optional

# -- Requests
class DashboardCreate(BaseModel):
    user_id: int

class DashboardUpdateTheme(BaseModel):
    dashboard_theme: str

class DashboardDelete(BaseModel):
    dashboard_id: int


# -- Responses
class DashboardResponse(BaseModel):
    dashboard_id: int
    user_id: int
    dashboard_theme: Optional[str] = None
