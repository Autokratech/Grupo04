from typing import Protocol

class IOrchestratorRepository(Protocol):
    
    async def get_active_tab_widgets(self, tab_id: int):
        pass
