from typing import Protocol

class ITabsRepository(Protocol):
    
    async def get_dashboard_tabs(self, dashboard_id : int):
        pass

    async def get_tab_by_id(self, tab_id: int):
        pass

    async def get_tab_max_index(self, dashboard_id: int):
        pass

    async def create_tab(self, dashboard_id : int, tab_name : str, tab_index : int):
        pass

    async def update_tab_name(self, tab_id : int, tab_name : str):
        pass

    async def update_tab_index(self, tab_id : int, tab_index : int):
        pass

    async def delete_tab(self, tab_id : int):
        pass
