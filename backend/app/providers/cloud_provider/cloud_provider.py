from .aws_provider import AWSProvider
from .azure_provider import AzureProvider
from .gcp_provider import GCPProvider
from app.services.oauth_manager import OAuthManager
from uuid import UUID


class CloudProvider():

    _cloud_provider_instance = {
        "aws": AWSProvider,
        "azure": AzureProvider,
        "gcp": GCPProvider
    }

    def __init__(self, oauth_manager: OAuthManager, endpoints_repository):
        self.oauth_manager = oauth_manager
        self.endpoints_repository = endpoints_repository

    async def get_provider_instance(self, provider_name : str, user_id: UUID):
        provider_instance = self._cloud_provider_instance[provider_name]
        if provider_instance is None:
            raise KeyError(f"No se ha encontrado el tipo de provider solicitado: {provider_name}.")

        access_token = await self.get_auth_token(user_id, provider_name)
        return provider_instance(self.endpoints_repository, access_token)


    async def get_auth_token(self, user_id: UUID, provider_name: str):
        decrypted_tokens, _ = await self.oauth_manager.fetch_oauth_tokens(user_id, provider_name)
        return decrypted_tokens["access_token"]
