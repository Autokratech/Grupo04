from supabase import AsyncClient
from app.core.exceptions import DatabaseError
from app.repositories.interfaces.widgets_interface import IWidgetsRepository
from uuid import UUID


class WidgetsRepository(IWidgetsRepository):

    #-- Tablas SQL de Supabase
    WIDGETS_TABLE = "widgets"

    def __init__(self, supabase: AsyncClient):
        self.supabase = supabase


    #-- Método para obtener los datos de un widget concreto en base a su id
    async def get_widget(self, widget_id : UUID):
        try:
            return await self.supabase.table(self.WIDGETS_TABLE) \
                .select('*') \
                .eq("widget_id", widget_id) \
                .single() \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para listar todos los widgets disponibles para un usuario
    async def get_all_available_widgets(self, available_providers):
        try:
            return await self.supabase.table(self.WIDGETS_TABLE) \
                .select("""widget_id, widget_type, widget_name,
                        widget_description, widget_function,
                        widget_data(data_id, data!inner(data_id, data_description, data_type,
                        data_providers!inner(provider_name)))""") \
                    .in_("widget_data.data.data_providers.provider_name", available_providers) \
                    .execute()
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para listar todos los widgets según el filtro especificado 
    async def search_widgets(self, widget_type : dict):
        try:
            return await self.supabase.table(self.WIDGETS_TABLE) \
                .select('*') \
                .eq(widget_type) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para crear un nuevo widget
    async def create_widget(self, widget_data : dict):
        try:
            return await self.supabase.table(self.WIDGETS_TABLE) \
                .insert(widget_data) \
                .execute()
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para actualizar parámetros de los widgets
    async def update_widget(self, widget_id, widget_data : dict):
        try:
            return await self.supabase.table(self.WIDGETS_TABLE) \
                .update(widget_data) \
                .eq("widget_id", widget_id) \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para eliminar un widget
    async def delete_widget(self, widget_id : UUID):
        try:
            return await self.supabase.table(self.WIDGETS_TABLE) \
                .delete() \
                .eq("widget_id", widget_id) \
                .execute()
        except DatabaseError as e:
            raise DatabaseError(e)