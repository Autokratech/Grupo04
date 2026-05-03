from requests_oauthlib import OAuth2Session
from app.services.oauth_config import oauth_config
from app.repositories.interfaces.oauth_manager_interface import IOAuthManagerRepository
from app.core.cryptography.crypto_manager import CryptoManager
from app.schemas.oauth_providers_schema import OAuthProviderResponse
from fastapi import HTTPException
from datetime import datetime, timezone
from uuid import UUID
import os

'''
Clase para gestionar la autenticación OAuth con los proveedores externos (métricas, recursos, etc)
que disponen de dicho tipo de sistema de autenticación (git_providers, cloud_providers...).
Se encarga de administrar los tokens de acceso y solicitar uno nuevo automáticamente cuando éste se encuetra caducado.
'''

class OAuthManager:

    #!-BORRAR
    os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"
    #!-BORRAR

    def __init__(self, repository: IOAuthManagerRepository, crypto_manager : CryptoManager):
        self.repository = repository  
        self.crypto_manager = crypto_manager
        self.kek_name = os.getenv("OAUTH_PROVIDERS_KEK_NAME")


    #-- Método para obtener la configuración específica del provider, definida en el fichero de configuración
    @staticmethod
    def get_oauth_config(provider_name):
        try:
            provider_config = oauth_config[provider_name]
            
            for key, value in provider_config.items():
                if not value:
                    raise ValueError(key)
            return provider_config
        
        except KeyError as e:
            raise HTTPException(status_code=404, detail=f"El provider {provider_name} no existe o no se ha podido obtener su configuración.")
        
        except ValueError as e:
            key = e.args[0]
            raise HTTPException(status_code=400, detail=f"La configuración del provider {provider_name} se encuentra incompleta: el valor de '{key}' está vacío.")


    #-- Método para crear una sesión OAuth a partir de la configuración específica del provider
    @staticmethod
    def get_oauth_session(provider_name):
        provider_config = OAuthManager.get_oauth_config(provider_name)

        extra_params = provider_config.get("extra_params", {})

        try:
            oauth = OAuth2Session(
                client_id=provider_config["client_id"], 
                redirect_uri=provider_config["redirect_url"], 
                scope=provider_config["scopes"]
            )
            
            auth_url, state = oauth.authorization_url(provider_config["auth_url"], **extra_params)
            return oauth, auth_url, state
        
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Se ha producido un error inesperado al intentar crear la sesión OAuth con el provider {provider_name}.")


    #-- Método para intercambiar el código de autorización proporcionado por un token de acceso
    @staticmethod
    def get_oauth_token(provider_name, authorization_response, state) -> OAuthProviderResponse:
        provider_config = OAuthManager.get_oauth_config(provider_name)

        try:
            oauth = OAuth2Session(
                client_id=provider_config["client_id"],
                redirect_uri=provider_config["redirect_url"],
                state=state
            )

            oauth_token_data = oauth.fetch_token(
                token_url=provider_config["token_url"],
                client_secret=provider_config["client_secret"],
                authorization_response=authorization_response
            )

            return OAuthProviderResponse(**oauth_token_data)
        except Exception as e:
            raise Exception(f"Se ha producido un error: {e}")


    #-- Método para incorproar un nuevo provider oauth para un usuario concreto
    async def create_user_oauth_provider(self, user_id : UUID, provider_name : str, oauth_token_data : OAuthProviderResponse):
        #TODO: Verificar que exista antes de intentar crearlo
        tokens_to_encrypt = {"access_token": oauth_token_data.access_token}
        if oauth_token_data.refresh_token is not None: tokens_to_encrypt.update({"refresh_token" : oauth_token_data.refresh_token})

        #Se encriptan los tokens antes de almacenarlos
        encrypted_tokens, wrapped_dek = await self.crypto_manager.encrypt_tokens_with_key_wrapping(tokens_to_encrypt, self.kek_name)
        return await self.repository.create_user_oauth_provider(user_id, provider_name, encrypted_tokens["access_token"], 
                                                                encrypted_tokens["refresh_token"], wrapped_dek,
                                                                oauth_token_data.created_at, oauth_token_data.expires_at)


    #-- Método para obtener el token oauth del usuario para el provider especificado
    async def fetch_oauth_tokens(self, user_id : UUID, provider_name : str):
        user_oauth_data = await self.repository.get_user_oauth_provider(user_id, provider_name)

        token_is_expired = user_oauth_data.expires_at < datetime.now(timezone.utc) 

        if not token_is_expired:
            encrypted_tokens = { "access_token" : user_oauth_data.access_token }
            if user_oauth_data.refresh_token is not None: encrypted_tokens.update({ "refresh_token" : user_oauth_data.refresh_token })
            decrypted_tokens, unwrapped_dek = await self.crypto_manager.decrypt_tokens_with_key_wrapping(encrypted_tokens, user_oauth_data.dek, self.kek_name)
            return decrypted_tokens, unwrapped_dek 
        else:
            return await self.refresh_access_token()


    #-- Método para obtener un access_token nuevo a partir del refresh_token, en aquellos provider que lo requieran
    async def refresh_access_token(self, oauth_refresh_token : bytes, provider_name : str):
        #TODO: Reimplementar, no todos los providers tienen refresh_token o lo gestionan de la misma forma
        #encrypted_tokens, wrapped_dek = await self.crypto_manager.encrypt_tokens_with_key_wrapping(tokens_to_encrypt, self.kek_name)
        pass

