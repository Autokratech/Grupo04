from typing import Protocol

class IDashboardRepository(Protocol):
    
    async def get_user_dashboard(self, user_id: int):
        pass

    async def create_dashboard(self, user_id: int): 
        pass

    async def update_dashboard_theme(self, dashboard_id: int, dashboard_theme: str):
        pass

    async def delete_dashboard(self, dashboard_id: int):
        pass