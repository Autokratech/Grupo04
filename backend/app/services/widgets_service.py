from app.repositories.interfaces.widgets_interface import IWidgetsRepository
from app.models.widget_model import *
from app.core.exceptions import DatabaseError
from uuid import UUID

class WidgetsService:

    def __init__(self, repository: IWidgetsRepository):
        self.repository = repository


    #Método para obtener el ID del dashboard asignado al usuario
    async def get_widget(self, widget_id : UUID):
        response = await self.repository.get_widget(widget_id)
        if not response.data:
            raise DatabaseError("No se encontró el widget solicitado.")
        return response.data


    #Método para obtener todos los widgets disponibles en la plataforma
    async def get_all_available_widgets(self):
        response = await self.repository.get_all_available_widgets()
        if not response.data:
            raise DatabaseError("No se han podido recuperar los widgets de la aplicación.")
        return response.data


    #-- Método para listar todos los widgets según el filtro especificado 
    async def search_widgets(self, widget_type : dict):
        response = await self.repository.search_widgets(widget_type)
        if not response.data:
            raise DatabaseError("No se ha encontrado ningún widget con los parámetros especificados.")
        return response.data


    #-- Método para crear un nuevo widget
    async def create_widget(self, widget_data : dict):
        response = await self.repository.create_widget(widget_data)
        if not response.data:
            raise DatabaseError("No se ha podido crear un nuevo widget con los parámetros proporcionados.")
        return response.data


    #-- Método para actualizar parámetros de los widgets
    async def update_widget(self, widget_id : UUID, widget_data : WidgetModel):
        item_exists = await self.repository.get_widget(widget_id)
        if not item_exists:
            raise DatabaseError("El widget especificado no existe.")
        response = await self.repository.update_widget(widget_id, widget_data)
        if not response.data:
            raise DatabaseError("No se ha podido actualizar el widget solicitado.")
        return response.data


    #-- Método para eliminar un widget
    async def delete_widget(self, widget_id : UUID):
        item_exists = await self.repository.get_widget(widget_id)
        if not item_exists:
            raise DatabaseError("El widget especificado no existe.")
        response = await self.repository.delete_widget(widget_id)
        if not response.data:
            raise DatabaseError("No se ha podido eliminar el widget solicitado.")
        return response.data

