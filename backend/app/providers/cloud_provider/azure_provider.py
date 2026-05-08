from app.repositories.interfaces.providers_interface import IProvidersRepository
from app.models.endpoint_model import * 
from app.schemas.providers.azure_schema import *
import httpx
import asyncio 
class AzureProvider():

    PROVIDER_NAME = "azure"
    #Importante! Para azure el base path es https://{servicio}.azure.com
    PROVIDER_PROTOCOL = "https://"
    PROVIDER_API_HOST="management.azure.com/subscriptions/"
    PROVIDER_SUBSCRIPTION_ID_ENDPOINT = "https://management.azure.com/subscriptions?api-version=2020-01-01"


    def __init__(self, repository: IProvidersRepository, access_token : str):
        self.repository = repository
        self.access_token = access_token

        self._schema_validator_types = {
            "RESOURCE_GROUPS" : ResourceGroup,
            "VIRTUAL_MACHINES" : VirtualMachine,
            "KEY_VAULTS" : KeyVault,
            "COST_MANAGEMENT" : CostManagement
        } 


    async def fetch_provider_data(self, data_type, data_config):
        full_endpoint = await self.get_provider_endpoint(data_type, data_config)
        
        if data_type == "COST_MANAGEMENT":  
            return await self.fetch_data_with_post(data_type, full_endpoint, data_config)
        else: 
            return await self.fetch_data_with_get(data_type, full_endpoint)

    
    async def fetch_data_with_get(self,data_type, full_endpoint):
        try:
            async with httpx.AsyncClient() as client:
                    response = await client.get(full_endpoint,
                    headers={'Authorization': f'Bearer {self.access_token}'})
            response.raise_for_status()
            return await self.normalize_response(data_type, response.json())
        except Exception as e:
            print(f"Execption: {e}")


    async def fetch_data_with_post(self,data_type, full_endpoint, data_config):
        print("data_config")
        try:
            async with httpx.AsyncClient() as client:
                    response = await client.post(full_endpoint,
                    json=data_config,
                    headers={'Authorization': f'Bearer {self.access_token}'})
            response.raise_for_status()
            return await self.normalize_response(data_type, response.json())
        except Exception as e:
            print(f"Execption: {e}")


    async def get_provider_endpoint(self, data_type, data_config):
        response = await self.repository.get_provider_endpoint(self.PROVIDER_NAME, data_type)
        if response.data is not None:
            #Se obtiene la suscripción de azure en la que se encuentra la cuenta vinculada
            subscription = await self.get_azure_subscription_id()
            endpoint_path = EndpointPath(**response.data[0])
            full_endpoint = self.PROVIDER_PROTOCOL + self.PROVIDER_API_HOST + subscription.id + endpoint_path.endpoint_path
            return full_endpoint
        else:
            return None


    async def get_azure_subscription_id(self):
        try:
            async with httpx.AsyncClient() as client:
                    response = await client.get(self.PROVIDER_SUBSCRIPTION_ID_ENDPOINT,
                    headers={'Authorization': f'Bearer {self.access_token}'})
            response.raise_for_status()        
            return SubscriptionID(**response.json())
        except Exception as e:
            print(f"execption: {e}")


    async def normalize_response(self, data_type, provider_response : dict):
        try:
            data_schema = self._schema_validator_types[data_type]
        except KeyError:
            raise KeyError("El tipo de datos especificado no está disponible para AZURE.")
        
        #Formateo extra necesario para pasar los ítems de las respuestas a formato lista siempre
        if isinstance(provider_response, dict) and "value" in provider_response:
            provider_response_items = provider_response["value"]
        elif isinstance(provider_response, list):
            provider_response_items = provider_response
        else:
            provider_response_items = [provider_response]

        response_items = [data_schema(**item) for item in provider_response_items]
        if data_type == "VIRTUAL_MACHINES":
            response_items = await self.load_virtual_machine_details(response_items)
        return AzureResponse(count=len(response_items), items=response_items).model_dump()


    async def load_virtual_machine_details(self, vms: list[VirtualMachine]):
        tasks = [self.get_vm_power_state(vm) for vm in vms]
        return await asyncio.gather(*tasks)


    #-- Método helper para aquellos items que requieren llamadas adicionales para obtener parámetros extra
    async def get_vm_power_state(self, azure_vm : VirtualMachine):
        vm_resource_group = azure_vm.id[azure_vm.id.find("/resourceGroups/") + len("/resourceGroups/") : azure_vm.id.find("/providers/")]

        subscription = await self.get_azure_subscription_id()

        general_vm_endpoint = await self.repository.get_provider_endpoint(self.PROVIDER_NAME, "VIRTUAL_MACHINES")
        general_vm_endpoint = EndpointPath(**general_vm_endpoint.data[0])
        specific_vm_endpoint = general_vm_endpoint.endpoint_path.replace("?", f"/{azure_vm.name}/instanceView?")
        full_endpoint_url = (f"{self.PROVIDER_PROTOCOL}{self.PROVIDER_API_HOST}{subscription.id}"
                            f"/resourceGroups/{vm_resource_group}{specific_vm_endpoint}")
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(full_endpoint_url, 
                                            headers={'Authorization': f'Bearer {self.access_token}'})
            response.raise_for_status()
            instance_view = VirtualMachineInstanceView(**response.json()) 
            azure_vm.power_state = instance_view.get_power_state() 
        except Exception as e:
            print(f"Error obteniendo power state de: {e}")
            azure_vm.power_state = None
        return azure_vm

#TODO: Gestionar los 404 cuando no encuentra el recurso (porque no existe, etc)
