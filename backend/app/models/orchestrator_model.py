from pydantic import BaseModel, model_validator
from typing import Dict, Any
from uuid import UUID


class TabWidget(BaseModel):
    tab_widget_id: UUID
    tab_id: UUID
    widget_id: UUID
    widget_type : str
    widget_title : str
    widget_index : int
    provider_name : str | None = None
    data_type : str | None = None
    custom_config: Dict[str, Any]  | None = None #Json < Revisar cómo implementar esta validación 
    widgets: Dict[str, Any] | None = None  #El nombre es lioso, pero es la key para los resultados del join con la tabla widgets (widget_type, widget_function, etc)


    @model_validator(mode="before")
    @classmethod
    def get_widget_data(cls, widget_data):
        widgets_object = widget_data.get("widgets", {})
        widget_data["widget_title"] = widgets_object.get("widget_name", {})
        widget_data["widget_type"] = widgets_object.get("widget_type", {})
    
        return widget_data
