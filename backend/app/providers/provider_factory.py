from .git_provider import *
from .cloud_provider import *
from .agent_provider import *
from app.repositories.interfaces.providers_interface import IProvidersRepository
from app.models.provider_model import *

'''
    Clase enmarcada en un Factory Pattern, que actúa como una fábrica de fábricas (factory of factories),
    encargada de generar una instancia específica del tipo de provider especificado en provider_type.

    La gestión del provider concreto (provider_name) es delegada a la fábrica dedicada a ese tipo de provider.
    Así, por ejemplo, GitProvider se encargará de crear instancias específicas del proveedor git concreto que 
    haya especificado en provider_name (como Gitlab, Github o Bitbucket).
    
'''

class ProviderFactory:
    _provider_factories_types = {
        "git_provider": GitProvider(),
        "cloud_provider": CloudProvider(),
        "agent_provider": AgentProvider()
    }


    def __init__(self, repository: IProvidersRepository):
        self.repository = repository


    async def create_provider_instance(self, provider_name: str):
        factory_type = await self.get_provider_factory_type(provider_name)
        provider_instance = await self.get_provider_instance(factory_type, provider_name)
        return provider_instance


    async def get_provider_factory_type(self, provider_name : str):
        response = await self.repository.get_provider_type(provider_name)
        provider = ProviderType(**response.data)

        provider_factory_type = self._provider_factories_types[provider.provider_type]
        if provider_factory_type is None:
            raise KeyError(f"No se ha encontrado el tipo de provider solicitado: {provider_factory_type}.")
        
        return provider_factory_type

        '''
        Una vez especificado el tipo de provider, en la factory de segundo nivel se obtiene la instancia específica 
        del mismo. Por ejemplo, si el tipo es Git, en la factory GitProvider se obtiene una instancia de Gitlab, 
        Github o Bitbucket.
        '''

    async def get_provider_instance(self, provider_factory_type : object, provider_name : str):
        return await provider_factory_type.get_provider_instance(provider_name)

