from fastapi import Depends
from typing import Annotated
from supabase import AsyncClient
from app.services.orchestrator_service import OrchestratorService
from app.repositories.orchestrator_repository import OrchestratorRepository
from app.repositories.providers_repository import ProvidersRepository
from app.repositories.endpoints_repository import EndpointsRepository
from app.providers.provider_factory import *
from app.core.database import create_supabase_client


# -- Preparación del servicio del orquestador e inyección de dependencias
async def get_orchestrator_service(supabase : AsyncClient = Depends(create_supabase_client)):
    orchestrator_repository = OrchestratorRepository(supabase)
    providers_repository = ProvidersRepository(supabase)
    endpoints_repository = EndpointsRepository(supabase)
    factory = ProviderFactory(providers_repository, endpoints_repository)

    return OrchestratorService(orchestrator_repository, factory)


# -- Referencia anotada para simplificar llamadas
orchestrator_service = Annotated[OrchestratorService, Depends(get_orchestrator_service)]


# -- Controladores para gestionar el orquestador
async def get_active_tab_widgets(tab_id: int, service: orchestrator_service):  
    return await service.orchestate_user_tab(tab_id)
