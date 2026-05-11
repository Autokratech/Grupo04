from typing import Protocol
from uuid import UUID

class IDashboardRepository(Protocol):
    
    async def get_user_dashboard(self, user_id: UUID):
        pass

    async def get_dashboard_by_id(self, dashboard_id: UUID):
        pass

    async def create_dashboard(self, dashboard_data : dict): 
        pass

    async def update_dashboard(self, dashboard_id: UUID, dashboard_data : dict):
        pass

    async def delete_dashboard(self, dashboard_id: UUID):
        pass
