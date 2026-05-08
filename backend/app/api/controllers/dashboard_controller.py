from fastapi import Depends, Request
from fastapi.responses import JSONResponse
from typing import Annotated
from supabase import AsyncClient
from uuid import UUID
from app.services.dashboard_service import DashboardService
from app.repositories.dashboard_repository import DashboardRepository
from app.schemas.dashboard_schema import DashboardCreate, DashboardUpdate
from app.core.database import create_supabase_client
from app.core.guardias import pedir_usuario_logueado


# -- Preparación del servicio de Dashboard e inyección de dependencias
async def get_dashboard_service(supabase : AsyncClient = Depends(create_supabase_client)):
    repository = DashboardRepository(supabase)
    return DashboardService(repository)


# -- Referencia anotada para simplificar llamadas
dashboard_service = Annotated[DashboardService, Depends(get_dashboard_service)]


# -- Controladores para gestionar el dashboard
async def get_user_dashboard(service: dashboard_service, usuario_actual=Depends(pedir_usuario_logueado)):
    user_id = UUID(usuario_actual["id"])
    return await service.get_user_dashboard(user_id)


async def create_dashboard(body: DashboardCreate, service: dashboard_service, usuario_actual=Depends(pedir_usuario_logueado)):
    user_id = UUID(usuario_actual["id"])
    return await service.create_dashboard(user_id, body.model_dump())


async def update_dashboard(dashboard_id: UUID, body: DashboardUpdate, service: dashboard_service):
    return await service.update_dashboard(dashboard_id, body.model_dump(exclude_none=True))


async def delete_dashboard(dashboard_id: UUID, service: dashboard_service):
    await service.delete_dashboard(dashboard_id)
    #Técnicamente el status_code debería ser 204, pero por consistencia interna con otros endpoints se queda como 200.
    return JSONResponse(status_code=200, content={"detail" : "El dashboard se ha eliminado correctamente."})
