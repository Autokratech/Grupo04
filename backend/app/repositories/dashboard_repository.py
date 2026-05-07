from supabase import AsyncClient
from app.core.exceptions import DatabaseError
from uuid import UUID

class DashboardRepository:
    
    #-- Tablas SQL de Supabase
    DASHBOARD_TABLE = "dashboards"

    def __init__(self, supabase: AsyncClient):
        self.supabase = supabase


    #-- Métodos para obtener el dashboard_id de un usuario concreto
    async def get_user_dashboard(self, user_id : UUID):
        try:
            return await self.supabase.table(self.DASHBOARD_TABLE) \
                .select("dashboard_id, dashboard_theme, dashboard_language") \
                .eq("user_id", user_id) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Métodos para obtener un dashboard concreto a partir del ID del mismo
    async def get_dashboard_by_id(self, dashboard_id : UUID):
        try:
            return await self.supabase.table(self.DASHBOARD_TABLE) \
                .select("dashboard_id, dashboard_theme, dashboard_language") \
                .eq("dashboard_id", dashboard_id) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)
        

    #-- Método para crear un dashboard nuevo
    async def create_dashboard(self, dashboard_data : dict):
        try:
            return await self.supabase.table(self.DASHBOARD_TABLE) \
                .insert(dashboard_data) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para actualizar el theme del dashboard
    async def update_dashboard(self, dashboard_id : UUID, dashboard_data : dict):
        try:
            return await self.supabase.table(self.DASHBOARD_TABLE) \
                .update(dashboard_data) \
                .eq("dashboard_id", dashboard_id) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para eliminar un dashboard
    async def delete_dashboard(self, dashboard_id : UUID):
        try:
            return await self.supabase.table(self.DASHBOARD_TABLE) \
                .delete() \
                .eq("dashboard_id", dashboard_id) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)
