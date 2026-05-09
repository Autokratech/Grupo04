from supabase import AsyncClient
from uuid import UUID
from app.core.exceptions import DatabaseError
from app.repositories.interfaces.providers_interface import IProvidersRepository


class ProvidersRepository(IProvidersRepository):

    #-- Tablas SQL de Supabase
    PROVIDERS_TABLE = "providers"
    USER_PROVIDERS_TABLE = "user_providers"

    def __init__(self, supabase: AsyncClient):
        self.supabase = supabase


    async def get_provider_type(self, provider_name: str):
        try:
            return await self.supabase.table(self.PROVIDERS_TABLE) \
                .select("provider_type") \
                .eq("provider_name", provider_name) \
                .single() \
                .execute()
        except DatabaseError as e:
            raise DatabaseError(e)


    async def get_user_available_providers(self, user_id: UUID):
        try:
            return await self.supabase.table(self.USER_PROVIDERS_TABLE) \
                .select("provider_name") \
                .eq("user_id", user_id) \
                .execute()
        except DatabaseError as e:
            raise DatabaseError(e)
