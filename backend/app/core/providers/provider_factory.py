from .git_provider import *
from .cloud_provider import *
from .agent_provider import *

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


    def get_provider_type(self, provider_type : str):

        provider_factory_type = self._provider_factories_types.get(provider_type)
        if provider_factory_type is None:
            raise KeyError(f"No se ha encontrado el tipo de provider solicitado: {provider_type}.")
        return provider_factory_type
        
        '''
        Una vez especificado el tipo de provider, en la factory de segundo nivel se obtiene la instancia específica 
        del mismo. Por ejemplo, si el tipo es Git, en la factory GitProvider se obtiene una instancia de Gitlab, 
        Github o Bitbucket.
        '''
    def get_provider_instance(self, provider_factory_type : object, provider_name : str):
        return provider_factory_type.get_provider_instance(provider_name)

