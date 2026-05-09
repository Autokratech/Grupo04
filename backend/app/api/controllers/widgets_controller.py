from fastapi import Depends
from typing import Annotated
from uuid import UUID
from supabase import AsyncClient
from app.services.widgets_service import WidgetsService
from app.repositories.widgets_repository import WidgetsRepository
from app.repositories.providers_repository import ProvidersRepository
from app.schemas.widget_schema import *
from app.core.database import create_supabase_client
from app.core.guardias import pedir_usuario_logueado


# -- Preparación del servicio de Widgets e inyección de dependencias
async def get_widgets_service(supabase : AsyncClient = Depends(create_supabase_client)):
    repository = WidgetsRepository(supabase)
    return WidgetsService(repository)


# -- Referencia anotada para simplificar llamadas
widgets_service = Annotated[WidgetsService, Depends(get_widgets_service)]


# -- Controladores para gestionar los widgets 
async def get_widget(widget_id : UUID, service: widgets_service):
    return await service.get_widget(widget_id)


async def get_all_available_widgets(service: widgets_service, supabase : AsyncClient = Depends(create_supabase_client), user=Depends(pedir_usuario_logueado)):
    #Apaño rápido para probar funcionalidad, TODO -> integrar correctamente
    provider_repository = ProvidersRepository(supabase)
    response = await provider_repository.get_user_available_providers(UUID(user["id"]))
    available_providers = []
    for provider in response.data:
        available_providers.append(provider["provider_name"])
    return await service.get_all_available_widgets(available_providers)


async def search_widgets(body : WidgetSearch, service: widgets_service):
    return await service.search_widgets(body.model_dump())


async def create_widget(body : WidgetCreate, service: widgets_service):
    return await service.create_widget(body.model_dump())


async def update_widget(widget_id : UUID, body : WidgetUpdate, service: widgets_service):
    print(body.model_dump())
    return await service.update_widget(widget_id, body.model_dump())


async def delete_widget(widget_id : UUID, service: widgets_service):
    return await service.delete_widget(widget_id)

