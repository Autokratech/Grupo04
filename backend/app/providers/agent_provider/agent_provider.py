from .windows_provider import WindowsProvider
from .linux_provider import LinuxProvider
from .macos_provider import MacOSProvider


class AgentProvider():

    _agent_provider_instance = {
        "windows": WindowsProvider,
        "linux": LinuxProvider,
        "macos": MacOSProvider
    }

    async def get_provider_instance(self, provider_name: str, endpoints_repository, user_id=None):

        provider_instance = self._agent_provider_instance.get(provider_name)
        if provider_instance is None:
            raise KeyError(f"No se ha encontrado el tipo de provider solicitado: {provider_name}.")

        return provider_instance(endpoints_repository)

    async def get_user_token(user_id : int, provider_name : str):
        pass