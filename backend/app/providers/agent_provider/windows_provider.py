from app.repositories.interfaces.agents_interface import IAgentsRepository
from app.schemas.providers.windows_agent_schema import *


class WindowsProvider():
    PROVIDER_NAME = "windows"

    def __init__(self, agents_repository: IAgentsRepository):
        self.repository = agents_repository


    async def fetch_provider_data(self, data_type, data_config):
        response = await self.repository.get_agent_metric(data_config["agent_id"])
        return WindowsAgentResponse(count=len(response.data), items=response.data).model_dump()
