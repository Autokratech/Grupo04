from .git_provider import *
from .cloud_provider import *
from .agent_provider import *
from app.repositories.interfaces.providers_interface import IProvidersRepository
from app.repositories.interfaces.endpoints_interface import IEndpointsRepository
from app.models.provider_model import *
from app.services.oauth_manager import OAuthManager
from uuid import UUID

'''
    Clase enmarcada en un Factory Pattern, que actúa como una fábrica de fábricas (factory of factories),
    encargada de generar una instancia específica del tipo de provider especificado en provider_type.

    La gestión del provider concreto (provider_name) es delegada a la fábrica dedicada a ese tipo de provider.
    Así, por ejemplo, GitProvider se encargará de crear instancias específicas del proveedor git concreto que 
    haya especificado en provider_name (como Gitlab, Github o Bitbucket).
    
'''

class ProviderFactory:

    def __init__(self, providers_repository: IProvidersRepository, endpoints_repository: IEndpointsRepository, oauth_manager : OAuthManager):
        self.providers_repository = providers_repository
        self.endpoints_repository  = endpoints_repository
        self.oauth_manager = oauth_manager

        self._provider_factory_types = {
            "git_provider":   GitProvider(oauth_manager),
            "cloud_provider": CloudProvider(oauth_manager),
            "agent_provider": AgentProvider()
        }


    async def create_provider_instance(self, user_id: UUID, provider_name: str):
        factory_type = await self.get_provider_factory_type(provider_name)
        provider_instance = await self.get_provider_instance(factory_type, provider_name, user_id)
        return provider_instance


    async def get_provider_factory_type(self, provider_name : str):
        response = await self.providers_repository.get_provider_type(provider_name)
        provider = ProviderType(**response.data)

        try:
            provider_factory_type = self._provider_factory_types[provider.provider_type]
        except KeyError:
            raise KeyError(f"No se ha encontrado el tipo de provider solicitado: {provider.provider_type}")
        except Exception as e:
            raise Exception(f"Se ha detectado un error inesperado : {e}")
        
        return provider_factory_type


        '''
        Una vez especificado el tipo de provider, en la factory de segundo nivel se obtiene la instancia específica 
        del mismo. Por ejemplo, si el tipo es Git, en la factory GitProvider se obtiene una instancia de Gitlab, 
        Github o Bitbucket.
        '''

    async def get_provider_instance(self, provider_factory_type : object, provider_name : str, user_id: UUID):
        return await provider_factory_type.get_provider_instance(provider_name, self.endpoints_repository, user_id)

