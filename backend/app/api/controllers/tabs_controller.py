from uuid import UUID
from typing import Annotated
#----------------------------------------------
from fastapi import Depends
from fastapi.responses import JSONResponse
from supabase import AsyncClient
#-----------------------------------------------
from app.services.tabs_service import TabsService
from app.repositories.tabs_repository import TabsRepository
from app.schemas.tab_schema import *
from app.core.database import create_supabase_client



# -- Preparación del servicio de Tabs e inyección de dependencias
async def get_tabs_service(supabase : AsyncClient = Depends(create_supabase_client)):
    repository = TabsRepository(supabase)
    return TabsService(repository)


# -- Referencia anotada para simplificar llamadas
tabs_service = Annotated[TabsService, Depends(get_tabs_service)]


'''
Endpoints de prueba para verificar el funcionamiento de la lógica interna, posteriormente
se validará la necesidad de cada uno
''' 

# -- Controladores para gestionar las pestañas del dashboard
async def get_dashboard_tabs(dashboard_id: UUID, service: tabs_service):
    return await service.get_dashboard_tabs(dashboard_id)


async def get_tab_by_id(dashboard_id : UUID, tab_id: UUID, service: tabs_service):
    return await service.get_tab_by_id(tab_id)


async def get_tab_max_index(dashboard_id: UUID, service: tabs_service):
    return await service.get_tab_max_index(dashboard_id)


async def create_tab(dashboard_id: UUID, body: TabCreate, service: tabs_service):
    return await service.create_tab(dashboard_id, body.model_dump())


async def update_tab(dashboard_id: UUID, tab_id : UUID, body: TabUpdate, service: tabs_service):
    return await service.update_tab(tab_id, body.model_dump(exclude_none=True))


async def delete_tab(dashboard_id: UUID, tab_id : UUID, service: tabs_service):
    await service.delete_tab(tab_id)
    #Técnicamente el status_code debería ser 204, pero por consistencia interna con otros endpoints se queda como 200.
    return JSONResponse(status_code=200, content={"detail" : "La tab especificada se ha eliminado correctamente."})
