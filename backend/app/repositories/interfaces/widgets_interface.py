from typing import Protocol

class IWidgetsRepository(Protocol):
    
    async def get_widget(self, widget_id : int):
        pass

    async def get_all_available_widgets(self):
        pass

    async def search_widgets(self, widget_type = dict):
        pass

    async def create_widget(self, widget_data : dict):
        pass

    async def update_widget(self, widget_id, widget_data : dict):
        pass

    async def delete_widget(self, widget_id : int):
        pass
