from supabase import AsyncClient
from app.core.exceptions import DatabaseError
from uuid import UUID

class AgentsRepository:
    
    #-- Tabla SQL de Supabase
    AGENT_METRICS_TABLE = "agent_metrics"

    def __init__(self, supabase: AsyncClient):
        self.supabase = supabase


    #-- Métodos para obtener el dashboard_id de un usuario concreto
    async def get_agent_metric(self, agent_id: UUID):
        try:
            return await self.supabase.table(self.AGENT_METRICS_TABLE) \
                .select('*') \
                .eq("agent_id", agent_id) \
                .limit(1) \
                .order("created_at", desc=True) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)
