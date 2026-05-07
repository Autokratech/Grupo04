from pydantic import BaseModel
from typing import List, Dict, Optional
  
#TODO: Organizar correctamente las clases y los modelos, de momento están así para pruebas rápidas

class Dashboard(BaseModel):
    dashboard_id: int
    user_id: int

class DashboardList(BaseModel):
    data: List[Dashboard]
    count: Optional[int] | None = None

class DashboardTabsResponse(BaseModel):
    data: Dict[int, str]