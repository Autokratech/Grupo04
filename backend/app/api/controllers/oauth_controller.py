from fastapi import Request, Response
from fastapi.responses import RedirectResponse
from fastapi import Depends
from typing import Annotated
from supabase import AsyncClient
from app.services.oauth_manager import OAuthManager
from app.repositories.oauth_manager_repository import OAuthManagerRepository
from app.core.cryptography.crypto_manager import CryptoManager
from app.core.cryptography.kms_providers.azure_kms import AzureKMSClient
from app.core.database import create_supabase_client




# -- Preparación del servicio OAuthManager e inyección de dependencias
async def get_oauth_manager(supabase : AsyncClient = Depends(create_supabase_client)):
    repository = OAuthManagerRepository(supabase)
    crypto_manager = CryptoManager(AzureKMSClient())
    return OAuthManager(repository, crypto_manager)

# -- Referencia anotada para simplificar llamadas
oauth_manager = Annotated[OAuthManager, Depends(get_oauth_manager)]

# -- Controladores para gestionar las conexiones OAuth
async def oauth_login(provider: str, response: Response):
    _, auth_url, state = OAuthManager.get_oauth_session(provider)
    response.set_cookie(key="state", value=state, httponly=True)
    return RedirectResponse(auth_url)


async def oauth_callback(provider: str, request: Request, manager: oauth_manager):
    state = request.cookies.get("state")
    provider_response = OAuthManager.get_oauth_token(provider, str(request.url), state)
    #!-- BORRAR, sólo para pruebas
    user_id = "3f9b6a2e-7c41-4d9f-9a8e-1b2c5e7d4f90"
    #!-- BORRAR, sólo para pruebas
    return await manager.create_user_oauth_provider(user_id, provider, provider_response)

