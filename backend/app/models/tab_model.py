from pydantic import BaseModel

class Tab(BaseModel):
    tab_id: int
    dashboard_id: int
    tab_name: str
    tab_index: int

class TabIndex(BaseModel):
    tab_index: int | None = 0
