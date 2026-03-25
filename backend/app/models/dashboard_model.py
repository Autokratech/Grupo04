from pydantic import BaseModel
from typing import List, Dict, Optional


class Dashboard(BaseModel):
    dashboard_id: int
    user_id: int
    dashboard_theme : str

class DashboardList(BaseModel):
    data: List[Dashboard]
    count: Optional[int] | None = None
