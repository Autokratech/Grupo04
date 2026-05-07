from uuid import UUID
from supabase import AsyncClient
from app.core.exceptions import DatabaseError


class TabsRepository:
    
    #-- Tablas SQL de Supabase
    TABS_TABLE = "tabs"

    def __init__(self, supabase: AsyncClient):
        self.supabase = supabase


    #-- Método para obtener las pestañas asociadas a un dashboard_id ordenadas según su índice
    async def get_dashboard_tabs(self, dashboard_id : UUID):
        try:
            return await self.supabase.table(self.TABS_TABLE) \
                .select("tab_id, tab_index, tab_name") \
                .eq("dashboard_id", dashboard_id) \
                .order("tab_index") \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    ##--- Método para obtener el ID de una pestaña en base a su índice
    async def get_tab_by_id(self, tab_id : UUID):
        try:
            return await self.supabase.table(self.TABS_TABLE) \
                .select('*') \
                .eq("tab_id" , tab_id) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para obtener el índice más alto de las tabs
    async def get_tab_max_index(self, dashboard_id: UUID):
        try:
            return await self.supabase.table(self.TABS_TABLE) \
                .select('tab_index') \
                .eq("dashboard_id", dashboard_id) \
                .order("tab_index", desc=True) \
                .limit(1) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para añadir una nueva pestaña al dashboard
    async def create_tab(self, tab_data : dict):
        try:
            return await self.supabase.table(self.TABS_TABLE) \
                .insert(tab_data) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para actualizar los parámetros de una pestaña del dashboard:
    async def update_tab(self, tab_id : UUID, tab_data : dict):
        try:
            return await self.supabase.table(self.TABS_TABLE) \
                .update(tab_data) \
                .eq("tab_id", tab_id) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para actualizar el índice de una pestaña del dashboard:
    async def update_tab_index(self, tab_id : UUID, tab_index : int):
        try:
            return await self.supabase.table(self.TABS_TABLE) \
                .update({"tab_index": tab_index}) \
                .eq("tab_id", tab_id) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #--- Método para eliminar una pestaña del dashboard 
    async def delete_tab(self, tab_id : UUID):
        try:
            return await self.supabase.table(self.TABS_TABLE) \
                .delete() \
                .eq("tab_id", tab_id) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)
