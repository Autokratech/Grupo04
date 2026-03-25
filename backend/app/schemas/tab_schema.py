from pydantic import BaseModel

#-- Requests
class TabCreate(BaseModel):
    tab_name : str | None = "new_tab"

class TabUpdate(BaseModel):
    tab_name : str | None = None
    tab_index : int | None = None

