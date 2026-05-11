from app.repositories.interfaces.agents_interface import IAgentsRepository
from app.schemas.providers.macos_agent_schema import *

class MacOSProvider():
    PROVIDER_NAME = "macos"

    def __init__(self, agents_repository: IAgentsRepository):
        self.repository = agents_repository


    async def fetch_provider_data(self, data_type, data_config):
        response = await self.repository.get_agent_metric(data_config["agent_id"])
        return MacOSAgentResponse(count=len(response.data), items=response.data).model_dump()
