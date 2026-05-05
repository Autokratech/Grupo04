from app.repositories.interfaces.providers_interface import IProvidersRepository
from app.models.endpoint_model import * 


class LinuxProvider():
    PROVIDER_NAME = "linux"

    def __init__(self, repository: IProvidersRepository):
        self.repository = repository


    async def fetch_provider_data(self, data_type, data_config):
        response = f"Respuesta fake de Linux, para {data_type} y {data_config}"
        return response

    #TODO: Definir la lógica para obtener los datos cuando se integren los agentes

