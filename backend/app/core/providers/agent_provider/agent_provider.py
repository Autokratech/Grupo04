from .windows_provider import WindowsProvider
from .linux_provider import LinuxProvider
from .macos_provider import MacOSProvider


class AgentProvider():

    _agent_provider_instance = {
        "windows": "WindowsProvider",
        "linux": "LinuxProvider",
        "macos": "MacOSProvider"
    }

    def get_provider_instance(self, provider_name : str, metric_type : str):

            provider_instance = self._agent_provider_instance(provider_name)
            if provider_instance is None:
                raise KeyError(f"No se ha encontrado el tipo de provider solicitado: {provider_name}.")
            
            provider_response = provider_instance.get_provider_metrics(metric_type)
            return provider_response

    def get_user_token(user_id : int, provider_name : str):
        pass