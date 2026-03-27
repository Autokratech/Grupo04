from app.repositories.interfaces.tabs_interface import ITabsRepository
from app.models.tab_model import *
from app.core.exceptions import DatabaseError
from uuid import UUID

''' 
Service para gestionar las pestañas del dashboard:
Se encarga de actualizar el orden, el nombre y otros parámetros intrínsecos de las pestañas, 
crearlas o eliminarlas.
'''

class TabsService:
    #Número máximo de tabs por Dashboard
    TABS_MAX_INDEX = 9

    def __init__(self, repository: ITabsRepository):
        self.repository = repository

    #-- Método para obtener las tabs asociadas a un dashboard en concreto
    async def get_dashboard_tabs(self, dashboard_id : UUID):
        response = await self.repository.get_dashboard_tabs(dashboard_id)
        if not response.data:
            raise DatabaseError("No se encontraron pestañas asociadas al dashboard del usuario.")
        return response.data


    #-- Método para obtener las tabs asociadas a un dashboard en concreto
    async def get_tab_by_id(self, tab_id : UUID):
        response = await self.repository.get_tab_by_id(tab_id)
        if not response.data:
            raise DatabaseError("No se encontró la pestaña asociada al id proporcionado.")
        return response.data
        

    #-- Método para obtener el índice de la pestaña más alta del dashboard (para crear una nueva pestaña)
    async def get_tab_max_index(self, dashboard_id: UUID):
        response = await self.repository.get_tab_max_index(dashboard_id)
        if not response.data:
            return None
        max_index = TabIndex(**response.data[0])
        print (f"max index es {max_index.tab_index}")
        return max_index.tab_index


    #-- Método para crear una nueva pestaña en el dashboard
    async def create_tab(self, dashboard_id : UUID, tab_name : str):
        actual_max_index = await self.get_tab_max_index(dashboard_id)
        if actual_max_index is None: 
            #Si no existe ninguna pestaña en el dashboard, se crea una nueva con índice 1
            new_tab_index = 1
        elif actual_max_index >= self.TABS_MAX_INDEX:
            raise TabError("El número máximo de pestañas disponibles es 9.")
        else:
            new_tab_index = actual_max_index + 1
        return await self.repository.create_tab(dashboard_id, tab_name, new_tab_index)


    #-- Método para actualizar el nombre de una pestaña
    async def update_tab_name(self, tab_id : UUID, tab_name : str):
        tab_exists = await self.repository.get_tab_by_id(tab_id)
        if tab_exists.data:
            return await self.repository.update_tab_name(tab_id, tab_name)


    #TODO: Revisar con Sammy cómo se implementará esto en el front (si cambiar un tab de sitio intercambia posiciones o desplaza a los siguientes)
    #Método para actualizar el índice de una pestaña
    async def arrange_tabs(self, tab_id : UUID):
        #tab_dashboard = self.get_tab_by_id(tab_id)
        #tabs_list = self.get_dashboard_tabs()
        #-- Lógica para actualizar el tab, pendiente revisar con front
        pass


    #-- Método para actualizar el índice de una tab
    async def update_tab_index(self, tab_id : UUID, tab_index : int):
        tab_exists = await self.repository.get_tab_by_id(tab_id)
        if tab_exists.data:
            return await self.repository.update_tab_index(tab_id, tab_index)


    #-- Método para eliminar una tab del dashboard
    async def delete_tab(self, tab_id : UUID):
        tab_exists = await self.repository.get_tab_by_id(tab_id)
        if tab_exists.data:
            return await self.repository.delete_tab(tab_id)
