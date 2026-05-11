from pydantic import BaseModel
from uuid import UUID

class TabModel(BaseModel):
    tab_id: UUID
    dashboard_id: UUID
    tab_name: str
    tab_index: int

class TabIndex(BaseModel):
    tab_index: int 
