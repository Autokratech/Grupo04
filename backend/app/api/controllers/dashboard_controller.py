from fastapi import Depends
from typing import Annotated
from supabase import AsyncClient
from app.services.dashboard_service import DashboardService
from app.repositories.dashboard_repository import DashboardRepository
from app.schemas.dashboard_schema import *
from app.core.database import create_supabase_client
from uuid import UUID


# -- Preparación del servicio de Dashboard e inyección de dependencias
async def get_dashboard_service(supabase : AsyncClient = Depends(create_supabase_client)):
    repository = DashboardRepository(supabase)
    return DashboardService(repository)


# -- Referencia anotada para simplificar llamadas
dashboard_service = Annotated[DashboardService, Depends(get_dashboard_service)]


# -- Controladores para gestionar el dashboard
async def get_user_dashboard(user_id: int, service: dashboard_service):  
    return await service.get_user_dashboard(user_id)


async def create_dashboard(body : DashboardCreate, service: dashboard_service):
    return await service.create_dashboard(body.dict())


async def update_dashboard(dashboard_id: UUID, body: DashboardUpdateTheme, service: dashboard_service):
    return await service.update_dashboard(dashboard_id, body.dashboard_theme)


async def delete_dashboard(dashboard_id: UUID, service: dashboard_service):
    return await service.delete_dashboard(dashboard_id)
