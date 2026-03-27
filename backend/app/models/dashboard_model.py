from pydantic import BaseModel
from typing import List, Dict, Optional
from uuid import UUID

class Dashboard(BaseModel):
    dashboard_id: UUID
    user_id: UUID
    dashboard_theme : str

class DashboardList(BaseModel):
    data: List[Dashboard]
    count: Optional[int] | None = None
