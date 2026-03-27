from pydantic import BaseModel


# -- Requests
class WidgetSearch(BaseModel):
    widget_type: str | None = None 
    widget_name : str | None = None 
    widget_function: str | None = None 
    

class WidgetCreate(BaseModel):
    widget_type: str 
    widget_name : str 
    widget_description: str | None = "Default description waiting to be updated."
    widget_function: str 


class WidgetUpdate(BaseModel):
    widget_type: str | None = None 
    widget_name : str | None = None 
    widget_description: str | None = None 
    widget_function: str | None = None 

