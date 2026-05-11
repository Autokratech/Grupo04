from typing import Protocol
from uuid import UUID


class ITabsRepository(Protocol):
    
    async def get_dashboard_tabs(self, dashboard_id : UUID):
        pass

    async def get_tab_by_id(self, tab_id : UUID):
        pass

    async def get_tab_max_index(self, dashboard_id: UUID):
        pass

    async def create_tab(self, tab_data : dict):
        pass

    async def update_tab(self, tab_id : UUID, tab_data : dict):
        pass

    async def update_tab_index(self, tab_id : UUID, tab_index : int):
        pass

    async def delete_tab(self, tab_id : UUID):
        pass
