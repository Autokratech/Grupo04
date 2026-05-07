from pydantic import BaseModel
from typing import List, Dict, Optional
from uuid import UUID

class DashboardTab(BaseModel):
    tab_id: UUID
    dashboard_id: UUID
    tab_name: str
    tab_index: int

class DashboardTabsList(BaseModel):
    data: List[DashboardTab]
    count: Optional[int] | None = None

class DashboardTabsResponse(BaseModel):
    data: Dict[int, str]