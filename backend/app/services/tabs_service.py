from uuid import UUID
from app.repositories.interfaces.tabs_interface import ITabsRepository
from app.models.tab_model import *
from app.schemas.tab_schema import *
from app.core.exceptions import DatabaseError, InvalidValueError


''' 
Service para gestionar las pestañas del dashboard:
Se encarga de actualizar el orden, el nombre y otros parámetros intrínsecos de las pestañas, 
crearlas o eliminarlas.
'''

class TabsService:
    #Número máximo de tabs por Dashboard
    TABS_MAX_INDEX = 5

    def __init__(self, repository: ITabsRepository):
        self.repository = repository

    #-- Método para obtener las tabs asociadas a un dashboard en concreto
    async def get_dashboard_tabs(self, dashboard_id : UUID):
        response = await self.repository.get_dashboard_tabs(dashboard_id)
        if not response.data:
            raise DatabaseError("No se encontraron pestañas asociadas al dashboard del usuario.")
        return TabListResponse(tabs=response.data)


    #-- Método para obtener la información de una tab en base a su id
    async def get_tab_by_id(self, tab_id : UUID):
        response = await self.repository.get_tab_by_id(tab_id)
        if not response.data:
            raise DatabaseError("No se ha encontrado la pestaña especificada.")
        return TabModel(**response.data[0])
    

    #-- Método para obtener el índice de la pestaña más alta del dashboard (para crear una nueva pestaña)
    async def get_tab_max_index(self, dashboard_id: UUID):
        response = await self.repository.get_tab_max_index(dashboard_id)
        if not response.data:
            return TabIndex(tab_index=0)
        return TabIndex(**response.data[0])


    #-- Método para crear una nueva pestaña en el dashboard
    async def create_tab(self, dashboard_id : UUID, tab_data : dict):
        tab_data.update({"dashboard_id" : str(dashboard_id)})

        actual_max_index = await self.get_tab_max_index(dashboard_id)
        next_tab_index = actual_max_index.tab_index + 1
    
        if tab_data["tab_index"] is None:
            if next_tab_index > self.TABS_MAX_INDEX:
                raise InvalidValueError(f"El número máximo de pestañas disponibles es {self.TABS_MAX_INDEX}")
            else:
                tab_data.update({"tab_index" : next_tab_index})
        elif tab_data["tab_index"] != next_tab_index:
            raise InvalidValueError(f"El valor proporcionado para el índice es incorrecto, debería ser: {next_tab_index}")
        
        response = await self.repository.create_tab(tab_data)
        return TabResponse(**response.data[0])

     
    #-- Método para actualizar los parámetros de una pestaña
    async def update_tab(self, tab_id : UUID, update_tab_data : dict):
        old_tab_data = await self.get_tab_by_id(tab_id)
        if not old_tab_data.tab_id:
            raise DatabaseError("No se ha encontrado la pestaña especificada.")

        if "tab_index" in update_tab_data:
            actual_max_index = await self.get_tab_max_index(old_tab_data.dashboard_id)
            if update_tab_data["tab_index"] > actual_max_index.tab_index:
                raise InvalidValueError(f"El nuevo valor proporcionado para el índice es incorrecto, el dashboard sólo dispone de {actual_max_index.tab_index} pestaña/s.")
            await self.arrange_tabs(tab_id, update_tab_data["tab_index"], old_tab_data.tab_index, old_tab_data.dashboard_id)
        response = await self.repository.update_tab(tab_id, update_tab_data)
        return TabResponse(**response.data[0])


    #-- Método para actualizar exclusivamente el índice de una pestaña, utilizado internamente por la clase
    async def update_tab_index(self, tab_id : UUID, tab_index : int):
        if tab_index >= self.TABS_MAX_INDEX:
            raise ValueError(f"El número máximo de pestañas disponibles es {self.TABS_MAX_INDEX}")
        elif tab_index < 0:
            raise ValueError(f"El índice mínimo para una Tab es 0.")
        tab_exists = await self.get_tab_by_id(tab_id)
        if not tab_exists.tab_id:
            raise DatabaseError("No se ha encontrado la pestaña especificada.")
        return await self.repository.update_tab_index(tab_id, tab_index)


    #-- Método para reorganizar las pestañas cuando se actualiza el índice
    async def arrange_tabs(self, tab_id : UUID, new_tab_index : int, old_tab_index : int, dashboard_id : UUID):        
        #Se calcula el sentido del desplazamiento, restando al índice viejo de la tab el nuevo
        index_shift = old_tab_index - new_tab_index if new_tab_index != 0 else 0
        print(f"new tab index is {new_tab_index}")
        print(f"old tab index is {old_tab_index}")
        #Se obtienen todas las tabs del dashboard al que pertenece la tab cuyo índice se quiere actualizar
        dashboard_tabs_list = await self.get_dashboard_tabs(dashboard_id)
        print(f"tab model dump es {dashboard_tabs_list.model_dump()}")
        tabs = dashboard_tabs_list.tabs

        for tab in tabs:
            if index_shift > 0 and tab.tab_id != tab_id:
                #Si es mayor que 0, la pestaña se ha desplazado hacia la izquierda <--. Sólo es necesario que se desplacen a la derecha las superiores a ésta
                if tab.tab_index >= new_tab_index:
                    await self.update_tab_index(tab.tab_id, tab.tab_index + 1)
            elif index_shift < 0 and tab.tab_id != tab_id:
                #Si es menor que 0, la pestaña se ha desplazado hacia la derecha -->. Sólo es necesario que se desplacen a la izquierda las superiores a ésta
                if tab.tab_index <= new_tab_index:
                    await self.update_tab_index(tab.tab_id, tab.tab_index - 1)
            elif index_shift == 0 and tab.tab_id != tab_id:
                #Casuística para contemplar el borrado de una tab
                if tab.tab_index > old_tab_index:
                    await self.update_tab_index(tab.tab_id, tab.tab_index - 1)


    #-- Método para eliminar una tab del dashboard
    async def delete_tab(self, tab_id : UUID):
        #Se verifica que la tab existe antes de intentar eliminarla
        tab_data = await self.get_tab_by_id(tab_id)
        if not tab_data.tab_id:
            raise DatabaseError("No se ha encontrado la pestaña especificada.")
        
        response = await self.repository.delete_tab(tab_id)
        if response.data:
            #Si se borra una TAB hay que obtener todas las anteriores y reducirles en 1 el índice
            await self.arrange_tabs(tab_id, 0, tab_data.tab_index, tab_data.dashboard_id)
            return response
