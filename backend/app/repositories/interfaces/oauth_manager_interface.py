from typing import Protocol

class IOAuthManagerRepository(Protocol):
    
    async def create_user_oauth_provider(self, user_id, provider_name : str, provider_token : str, refresh_token : str, dek, expiration_data):
        pass


    async def update_user_oauth_provider(self, user_id, provider_name : str, update_params : dict):
        pass

