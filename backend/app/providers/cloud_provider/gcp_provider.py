from app.repositories.interfaces.providers_interface import IProvidersRepository
from app.models.endpoint_model import * 
from app.schemas.providers.gcp_schema import *
import httpx, asyncio

'''
Clase para la obtención de métricas del provider GCP. 
La API de GCP requiere consultar los recursos por cada proyecto, por lo que es necesario agregarlos posteriormente.
'''
class GCPProvider():

    PROVIDER_NAME = "gcp"
    #Importante! Para gcp el base path es https://{servicio}.googleapis.com
    PROVIDER_PROTOCOL = "https://"
    PROVIDER_API_HOST = {
        "VIRTUAL_MACHINES": "compute.googleapis.com/compute/v1/projects/",
        "DATABASES": "sqladmin.googleapis.com/sql/v1beta4/projects/",
        "COST_MANAGEMENT": "cloudbilling.googleapis.com"
    }
    PROVIDER_PROJECT_ID_ENDPOINT="cloudresourcemanager.googleapis.com/v1/projects"

 # + ARTIFACT REGISTRY + DATABASES  (RESOURCE GROUPS NO HAY, NI KEY VAULTS, gcp secret manager es sólo un servicio)
    def __init__(self, repository: IProvidersRepository, access_token : str):
        self.repository = repository
        self.access_token = access_token

        self._schema_validator_types = {
            "VIRTUAL_MACHINES" : ComputeInstanceList,  #Devuelve todo aggregated, así que se gestiona en una lista
            "SQL_DATABASES" : SQLDatabaseList
            #"COST_MANAGEMENT" : BillingReport
        } 


    async def fetch_provider_data(self, data_type, data_config):
        projects_list = await self.get_gcp_projects_id()
        tasks = [self.fetch_data_with_get(data_type, project.projectId) for project in projects_list]
        projects_data = await asyncio.gather(*tasks)

        #Es necesario agregar todas las consultas antes de devolver la respuesta al orquestador
        aggregated_projects_data = []
        for project in projects_data:
                aggregated_projects_data.extend(project.items)

        return GCPResponse(count=len(aggregated_projects_data), items=aggregated_projects_data).model_dump()

    
    async def fetch_data_with_get(self, data_type, project_id):
        full_endpoint = await self.get_provider_endpoint(data_type, project_id)
        try:
            async with httpx.AsyncClient() as client:
                    response = await client.get(full_endpoint,
                    headers={'Authorization': f'Bearer {self.access_token}'})
            response.raise_for_status()
            return await self.normalize_response(data_type, response.json())
        except Exception as e:
            print(f"Execption: {e}")


    async def get_gcp_projects_id(self):
        try:
            async with httpx.AsyncClient() as client:
                    response = await client.get(self.PROVIDER_PROTOCOL + self.PROVIDER_PROJECT_ID_ENDPOINT,
                    headers={'Authorization': f'Bearer {self.access_token}'})
            response.raise_for_status()    
            return ProjectList(**response.json())
        except Exception as e:
            print(f"execption: {e}")


    async def get_provider_endpoint(self, data_type, project_id):
        response = await self.repository.get_provider_endpoint(self.PROVIDER_NAME, data_type)
        if response.data is not None:
            endpoint_path = EndpointPath(**response.data[0])
            full_endpoint = self.PROVIDER_PROTOCOL + self.PROVIDER_API_HOST[data_type] + project_id + endpoint_path.endpoint_path
            print(f"full endpoint is ... {full_endpoint}")
            return full_endpoint
        else:
            return None


    
    async def normalize_response(self, data_type, provider_response : dict):
        try:
            data_schema = self._schema_validator_types[data_type]
        except KeyError:
            raise KeyError("El tipo de datos especificado no está disponible para Google Cloud.")
        return data_schema(**provider_response) 
        
