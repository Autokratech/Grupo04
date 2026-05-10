from app.repositories.interfaces.providers_interface import IProvidersRepository
from app.models.endpoint_model import * 
from app.schemas.providers.gitlab_schema import *
import httpx

class GitlabProvider():
    
    #!TODO:Migrar esto a variables de entorno
    #Posibles mejoras: permitir más de una instancia de gitlab/etc
    PROVIDER_NAME = "gitlab"
    PROVIDER_PROTOCOL = "https://"
    PROVIDER_API_HOST="gitlab.com/api/v4" 

    def __init__(self, repository: IProvidersRepository, access_token: str):
        self.repository = repository
        self.access_token = access_token

        self._schema_validator_types = {
            "ISSUES": Issue,
            "MERGE_REQUESTS": MergeRequest,
            "PROJECTS" : Project,
            "PIPELINES" : Pipeline
        }


    async def fetch_provider_data(self, data_type, data_config):
        full_endpoint = await self.get_provider_endpoint(data_type, data_config)
        try:
            async with httpx.AsyncClient() as client:
                    response = await client.get(full_endpoint,
                    headers={'Authorization': f'Bearer {self.access_token}'})
            response.raise_for_status()
            return await self.normalize_response(data_type, response.json())
        except Exception as e:
            print(f"execption: {e}")
        #TODO:  Añadir configuración personalizada del user


    async def get_provider_endpoint(self, data_type, data_config):
        response = await self.repository.get_provider_endpoint(self.PROVIDER_NAME, data_type)
        if response.data is not None:
            endpoint_path = EndpointPath(**response.data[0])
            full_endpoint = self.PROVIDER_PROTOCOL + self.PROVIDER_API_HOST + endpoint_path.endpoint_path
            return full_endpoint
        else:
            return None


    async def normalize_response(self, data_type, provider_response : dict):
        try:
            data_schema = self._schema_validator_types[data_type]
        except KeyError:
            raise KeyError("El tipo de datos especificado no está disponible para GITLAB.")
        response_items = [data_schema(**item) for item in provider_response]
        return GitlabResponse(count=len(response_items), items=response_items).model_dump()

