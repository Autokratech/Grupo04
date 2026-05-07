from supabase import AsyncClient
from app.core.exceptions import DatabaseError
from app.repositories.interfaces.providers_interface import IProvidersRepository


class ProvidersRepository(IProvidersRepository):

    #-- Tabla SQL de Supabase
    PROVIDERS_TABLE = "providers"


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
