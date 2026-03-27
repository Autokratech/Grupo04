from supabase import AsyncClient
from app.core.exceptions import DatabaseError
from app.repositories.interfaces.orchestrator_interface import IOrchestratorRepository
from uuid import UUID

class OrchestratorRepository(IOrchestratorRepository):

    #-- Tablas SQL de Supabase
    TAB_WIDGETS_TABLE = "tab_widgets"


    def __init__(self, supabase: AsyncClient):
        self.supabase = supabase

    async def get_active_tab_widgets(self, tab_id: UUID):
        try:
            return await self.supabase.table(self.TAB_WIDGETS_TABLE) \
                .select("*, widgets(widget_type, widget_name)") \
                .eq("tab_id", tab_id) \
                .order("widget_index") \
                .execute()
        except DatabaseError as e:
            raise DatabaseError(e)
