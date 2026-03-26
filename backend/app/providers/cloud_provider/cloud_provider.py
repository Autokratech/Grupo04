from .aws_provider import AWSProvider
from .azure_provider import AzureProvider
from .gcp_provider import GCPProvider

class CloudProvider():

    _cloud_provider_instance = {
        "aws": AWSProvider(),
        "azure": AzureProvider(),
        "gcp": GCPProvider()
    }

    async def get_provider_instance(self, provider_name : str):

        provider_instance = self._cloud_provider_instance[provider_name]
        if provider_instance is None:
            raise KeyError(f"No se ha encontrado el tipo de provider solicitado: {provider_name}.")
        
        #provider_response = provider_instance.get_provider_metrics(metric_type)
        #return provider_response

        return provider_instance

    async def get_user_token(user_id : int, provider_name : str):
        pass