from fastapi import Depends
from typing import Annotated
from supabase import AsyncClient
from collections.abc import AsyncIterable
from fastapi.sse import EventSourceResponse, ServerSentEvent
from app.services.orchestrator_service import OrchestratorService
from app.repositories.orchestrator_repository import OrchestratorRepository
from app.repositories.oauth_manager_repository import OAuthManagerRepository
from app.repositories.providers_repository import ProvidersRepository
from app.repositories.endpoints_repository import EndpointsRepository
from app.providers.provider_factory import *
from app.core.cryptography.crypto_manager import CryptoManager
from app.core.cryptography.kms_providers.azure_kms import AzureKMSClient
from app.core.database import create_supabase_client
from uuid import UUID

# -- Preparación del servicio del orquestador e inyección de dependencias
async def get_orchestrator_service(supabase : AsyncClient = Depends(create_supabase_client)):
    #TODO: Desacoplar el KMS client concreto de aquí, llevar esto a otro fichero, después de implementar el de GCP
    kms_client = AzureKMSClient()
    crypto_manager = CryptoManager(kms_client)
    oauth_repository = OAuthManagerRepository(supabase)
    oauth_manager = OAuthManager(oauth_repository, crypto_manager)

    orchestrator_repository = OrchestratorRepository(supabase)
    providers_repository = ProvidersRepository(supabase)
    endpoints_repository = EndpointsRepository(supabase)
    factory = ProviderFactory(providers_repository, endpoints_repository, oauth_manager)

    return OrchestratorService(orchestrator_repository, factory)


# -- Referencia anotada para simplificar llamadas
orchestrator_service = Annotated[OrchestratorService, Depends(get_orchestrator_service)]


# -- Controladores para gestionar el orquestador
#-!BORRAR Solicitud user_id, obtener de la sesión, revisar en base a lo integrado en el auth
async def get_active_tab_widgets(user_id: UUID, dashboard_id : UUID, tab_id: UUID, service: orchestrator_service)-> AsyncIterable[ServerSentEvent]: 
    async for event in service.orchestate_user_tab(user_id, tab_id):
        yield ServerSentEvent(data=event["data"], event=event["event"])

#REVISAR: https://fastapi.tiangolo.com/tutorial/server-sent-events/#serversentevent