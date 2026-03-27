from supabase import AsyncClient
from app.core.exceptions import DatabaseError


class WidgetsRepository:
    
    #-- Tablas SQL de Supabase
    WIDGETS_TABLE = "widgets"

    def __init__(self, supabase: AsyncClient):
        self.supabase = supabase


    #-- Método para obtener los datos de un widget concreto en base a su id
    async def get_widget(self, widget_id : int):
        try:
            return await self.supabase.table(self.WIDGETS_TABLE) \
                .select('*') \
                .eq("widget_id", widget_id) \
                .single() \
                .execute() 
        except DatabaseError as e:
            raise DatabaseError(e)


    #-- Método para listar todos los widgets implementados 
    async def get_all_available_widgets(self):
        try:
            return await self.supabase.table(self.WIDGETS_TABLE) \
                .select('*') \
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
    async def delete_widget(self, widget_id : int):
        try:
            return await self.supabase.table(self.WIDGETS_TABLE) \
                .delete() \
                .eq("widget_id", widget_id) \
                .execute()
        except DatabaseError as e:
            raise DatabaseError(e)

