from uuid import UUID
from app.repositories.interfaces.agents_interface import IAgentsRepository
from .windows_provider import WindowsProvider
from .linux_provider import LinuxProvider
from .macos_provider import MacOSProvider


class AgentProvider():

    _agent_provider_instance = {
        "windows": WindowsProvider,
        "linux": LinuxProvider,
        "macos": MacOSProvider
    }

    def __init__(self, repository: IAgentsRepository):
        self.repository = repository  

    async def get_provider_instance(self, provider_name : str, user_id: UUID):
        provider_instance = self._agent_provider_instance[provider_name]
        if provider_instance is None:
            raise KeyError(f"No se ha encontrado el tipo de provider solicitado: {provider_name}.")
        return provider_instance(self.repository)

    async def get_user_token(user_id : int, provider_name : str):
        pass
