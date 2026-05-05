from supabase import AsyncClient
from app.core.exceptions import DatabaseError


class EndpointsRepository:
    
    #-- Tabla SQL de Supabase
    ENDPOINTS_TABLE = "endpoints"

    def __init__(self, supabase: AsyncClient):
        self.supabase = supabase


    #-- Métodos para obtener el dashboard_id de un usuario concreto
    async def get_provider_endpoint(self, provider_name : str, data_type : str):
        try:
            return await self.supabase.table(self.ENDPOINTS_TABLE) \
                .select('endpoint_path') \
                .match({"provider_name" : provider_name, 
                        "data_type" : data_type}) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)
