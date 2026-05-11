from pydantic import BaseModel, Field
from typing import Dict, List, Any
from uuid import UUID


class TabWidgetSkeleton(BaseModel):
    tab_widget_id : UUID
    widget_type : str
    widget_title : str | None = None #Pendiente incorporar este campo vía código y actualizar en la bbdd
    widget_index : int
    data_type : str
    custom_config: Dict[str, Any]  | None = None #Json < Revisar cómo implementar esta validación 


class TabWidgeSkeletontList(BaseModel):
    tab_widgets : List[TabWidgetSkeleton]


class Data(BaseModel):
    count : int
    items : List[Dict]  #Los campos concretos aquí ya dependen del recurso


class TabWidgetData(BaseModel):
    tab_widget_id : UUID
    provider_tag : str
    status : str | None = "success" #TODO: Migrar a enum una vez decididos los tipos disponibles en status
    timestamp : str | None = None
    ttl : int | None = None #TODO: Crear una nueva tabla data_types con este tipo de info
    data : Data | None = None


class TabWidgetDataList(BaseModel):
    tab_widgets_data : List[TabWidgetData]


class AddTabWidgetResponse(BaseModel):
    tab_id: UUID
    widget_id: UUID
    tab_widget_id: UUID
    widget_index: int

# Requests 

class ProviderData(BaseModel):
    tab_widget_id : UUID
    provider_name :  str 
    data_type : str
    custom_config : dict

class ProviderRequestList(BaseModel):
    providers : List[ProviderData]


class AddTabWidget(BaseModel):
    widget_id: UUID
    widget_index: int | None = None
    provider_name: str
    custom_config: dict | None = None
    data_type: str