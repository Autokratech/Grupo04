from typing import Protocol

class IEndpointsRepository(Protocol):
    
    async def get_provider_endpoint(self, provider_name : str, data_type : str):
        pass
