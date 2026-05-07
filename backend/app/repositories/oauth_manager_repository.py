from supabase import AsyncClient
from app.core.exceptions import DatabaseError
from app.repositories.interfaces.oauth_manager_interface import IOAuthManagerRepository
from app.models.user_oauth_provider_model import UserOAuthProvider
from uuid import UUID

class OAuthManagerRepository(IOAuthManagerRepository):

    #-- Tablas SQL de Supabase
    OAUTH_USER_PROVIDERS = "user_oauth_providers"


    def __init__(self, supabase: AsyncClient):
        self.supabase = supabase


    async def get_user_oauth_provider(self, user_id : UUID, provider_name : str):
        try:
            response = await self.supabase.table(self.OAUTH_USER_PROVIDERS) \
                .select('*') \
                .match({"user_id" : user_id,
                        "provider_name" : provider_name}) \
                .execute() 
        
            if not response.data:
                raise ValueError(f"No se ha encontrado el provider '{provider_name}' para el usuario '{user_id}'.")

            return UserOAuthProvider(**response.data[0])
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para vincular un nuevo provider al usuario especificado
    async def create_user_oauth_provider(self, user_id : UUID, provider_name : str, access_token : str, refresh_token : str, dek, created_at, expires_at):
        try:
            return await self.supabase.table(self.OAUTH_USER_PROVIDERS) \
                .insert({'user_id' : user_id, 
                         'provider_name' : provider_name, 
                         'access_token' : access_token,
                         'refresh_token' : refresh_token,
                         'dek' : dek,
                         'created_at' : created_at.isoformat(),
                         'expires_at' : expires_at.isoformat()
                         }) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para actualizar los parámetros del provider (access_token, refresh_token, dek, expiration_time)
    async def update_user_oauth_provider(self, user_id, provider_name : str, update_params : dict):
        try:
            return await self.supabase.table(self.OAUTH_USER_PROVIDERS) \
                .update(update_params) \
                .match({"user_id" : user_id, "provider_name" : provider_name}) \
                .execute()
        except DatabaseError as e:
            raise DatabaseError(e)

