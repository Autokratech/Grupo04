from typing import Annotated
from uuid import UUID
from supabase import AsyncClient
from collections.abc import AsyncIterable
from fastapi import Depends
from fastapi.sse import ServerSentEvent
from app.services.orchestrator_service import OrchestratorService
from app.schemas.orchestrator_schema import AddTabWidget
from app.repositories.orchestrator_repository import OrchestratorRepository
from app.repositories.oauth_manager_repository import OAuthManagerRepository
from app.repositories.providers_repository import ProvidersRepository
from app.repositories.agents_repository import AgentsRepository
from app.repositories.endpoints_repository import EndpointsRepository
from app.providers.provider_factory import *
from app.core.cryptography.crypto_manager import CryptoManager
from app.core.cryptography.kms_providers.azure_kms import AzureKMSClient
from app.core.database import create_supabase_client
from app.core.guardias import pedir_usuario_logueado

# -- Preparación del servicio del orquestador e inyección de dependencias
async def get_orchestrator_service(supabase : AsyncClient = Depends(create_supabase_client)):
    #TODO: Desacoplar el KMS client concreto de aquí, llevar esto a otro fichero, después de implementar el de GCP
    kms_client = AzureKMSClient()
    crypto_manager = CryptoManager(kms_client)
    oauth_repository = OAuthManagerRepository(supabase)
    oauth_manager = OAuthManager(oauth_repository, crypto_manager)

    orchestrator_repository = OrchestratorRepository(supabase)
    agents_repository = AgentsRepository(supabase)
    providers_repository = ProvidersRepository(supabase)
    endpoints_repository = EndpointsRepository(supabase)
    factory = ProviderFactory(providers_repository, endpoints_repository, agents_repository, oauth_manager)

    return OrchestratorService(orchestrator_repository, factory)


# -- Referencia anotada para simplificar llamadas
orchestrator_service = Annotated[OrchestratorService, Depends(get_orchestrator_service)]


# -- Controladores para gestionar el orquestador
#- La solicitud de dashboard_id es innecesaria, pero se realiza para mantener la coherencia con los endpoints
async def get_active_tab_widgets(dashboard_id : UUID, tab_id: UUID, service: orchestrator_service, user=Depends(pedir_usuario_logueado))-> AsyncIterable[ServerSentEvent]: 
    async for event in service.orchestate_user_tab(UUID(user["id"]), tab_id):
        yield ServerSentEvent(data=event["data"], event=event["event"])

async def add_widget_to_active_tab(dashboard_id : UUID, tab_id: UUID, body: AddTabWidget, service: orchestrator_service): 
    return await service.add_widget_to_active_tab(tab_id, body.model_dump(mode="json"))
