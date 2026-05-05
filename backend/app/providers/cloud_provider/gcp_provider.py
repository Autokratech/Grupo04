from app.repositories.interfaces.providers_interface import IProvidersRepository
from app.models.endpoint_model import * 
import httpx


class GCPProvider():

    PROVIDER_NAME = "gcp"
    #Importante! Para gcp el base path es https://{servicio}.googleapis.com
    PROVIDER_PROTOCOL = "https://"
    PROVIDER_API_HOST="googleapis.com"


    def __init__(self, repository: IProvidersRepository):
        self.repository = repository


    async def fetch_provider_data(self, data_type, data_config):
        response = await self.get_provider_endpoint(data_type, data_config)
        #TODO: Añadir configuración personalizada del user, realizar llamada con httpx + postprocesamiento de la respuesta de gitlab
        return response
    
    async def get_provider_endpoint(self, data_type, data_config):
        response = await self.repository.get_provider_endpoint(self.PROVIDER_NAME, data_type)
        if response.data is not None:
            endpoint_path = EndpointPath(**response.data[0])
            full_endpoint = self.PROVIDER_PROTOCOL + self.PROVIDER_API_HOST + endpoint_path.endpoint_path
            return print(full_endpoint)
        else:
            return None

    async def normalize_response(provider_response):
        pass

    #TODO: Idea. Añadir métodos que permitan obtener métricas combinadas, más complejas