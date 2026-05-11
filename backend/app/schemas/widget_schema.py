from pydantic import BaseModel, model_validator
from uuid import UUID


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


# -- Responses
class WidgetData(BaseModel):
    data_type: str | None = None
    data_description: str | None = None
    data_providers: list[str] = []

class AvailableWidget(BaseModel):
    widget_id: UUID
    widget_type: str
    widget_name: str
    widget_description: str | None = None
    widget_function: str | None = None
    widget_data_types: list[WidgetData] = []

    @model_validator(mode="before")
    @classmethod
    def get_widget_data(cls, widget_data):
        data_list = widget_data.get("widget_data", [])

        widget_data_types = []

        for data in data_list:
            data_type = data.get("data") or {}  # ← el dict está dentro de item["data"]

            widget_data_types.append({
            "data_type" : data_type.get("data_type"),
            "data_description": data_type.get("data_description"),
            "data_providers" : [provider.get("provider_name") for provider in data_type.get("data_providers", [])]
            })
        
        widget_data["widget_data_types"] = widget_data_types
        return widget_data


class AvailableWidgetsResponse(BaseModel):
    total_widgets: int
    widgets: list[AvailableWidget]