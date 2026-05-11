from typing import Protocol
from uuid import UUID

class IAgentsRepository(Protocol):
    
    async def get_agent_metric(self, user_id: UUID, agent_id: UUID):
        pass
