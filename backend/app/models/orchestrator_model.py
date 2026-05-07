from pydantic import BaseModel, Json
from typing import Dict, List, Any


class TabWidget(BaseModel):
    tab_widget_id: int
    tab_id: int
    widget_id: int
    widget_index : int
    provider_name : str | None = None
    data_type : str | None = None
    custom_config: Dict[str, Any]  | None = None #Json < Revisar cómo implementar esta validación 
    widgets: Dict[str, Any] | None = None  #El nombre es lioso, pero es la key para los resultados del join con la tabla widgets (widget_type, widget_function, etc)
