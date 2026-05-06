from pydantic import BaseModel
from typing import List
from uuid import UUID

#-- Requests
class TabCreate(BaseModel):
    tab_name : str | None = "new_tab"

class TabUpdate(BaseModel):
    tab_name : str | None = None
    tab_index : int | None = None

#-- Responses
class Tab(BaseModel):
    tab_id : UUID
    tab_index : int
    tab_name : str

class TabsListResponse(BaseModel):
    tabs : List[Tab]
