from typing import Protocol

class IProvidersRepository(Protocol):
    
    async def get_provider_type(self, provider_name : str):
        pass
