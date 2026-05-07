from pydantic import BaseModel
from typing import List
from uuid import UUID

class Dashboard(BaseModel):
    dashboard_id: UUID
    user_id: UUID
    dashboard_theme : str
    dashboard_language : str 

class DashboardCreate(BaseModel):
    user_id: UUID
    dashboard_theme : str | None = "classic"
    dashboard_language : str | None = "spanish"

class DashboardUpdate(BaseModel):
    dashboard_theme : str | None = None
    dashboard_language : str | None = None

class DashboardList(BaseModel):
    data: List[Dashboard]
    count: int | None = None
