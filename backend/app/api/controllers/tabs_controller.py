from fastapi import Depends
from typing import Annotated
from supabase import AsyncClient
from app.services.tabs_service import TabsService
from app.repositories.tabs_repository import TabsRepository
from app.schemas.tab_schema import *
from app.core.database import create_supabase_client
from uuid import UUID


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


async def get_tab_by_id(tab_id: UUID, service: tabs_service):
    return await service.get_tab_by_id(tab_id)


async def get_tab_max_index(dashboard_id: UUID, service: tabs_service):
    return await service.get_tab_max_index(dashboard_id)


async def create_tab(dashboard_id: UUID, body: TabCreate, service: tabs_service):
    return await service.create_tab(dashboard_id, body.tab_name)


async def update_tab(tab_id : UUID, body: TabUpdate, service: tabs_service):
    if body.tab_name is not None:
        await service.update_tab_name(tab_id, body.tab_name)
    if body.tab_index is not None:
        await service.update_tab_index(tab_id, body.tab_index)


async def delete_tab(tab_id : UUID, service: tabs_service):
    return await service.delete_tab(tab_id)
