from app.repositories.interfaces.dashboard_interface import IDashboardRepository
from app.schemas.dashboard_schema import DashboardResponse
from app.core.exceptions import DatabaseError
from uuid import UUID

class DashboardService:

    def __init__(self, repository: IDashboardRepository):
        self.repository = repository


    #-- Método para obtener el ID del dashboard asignado al usuario
    async def get_user_dashboard(self, user_id : int):
        response = await self.repository.get_user_dashboard(user_id)
        if not response.data:
            raise DatabaseError("No se encontró el dashboard del usuario.")
        return DashboardResponse(**response.data[0])


    #-- Método para crear un nuevo dashboard para el usuario recién añadido: 
    async def create_dashboard(self, user_id : UUID, dashboard_data : dict):
        #Se verifica que el usuario especificado NO dispone de un dashboard antes de intentar crearlo
        has_dashboard = await self.repository.get_user_dashboard(user_id)
        if has_dashboard.data:
            raise DatabaseError("El usuario ya dispone de un dashboard asignado.")
        
        dashboard_data.update({"user_id" : str(user_id)})
        response = await self.repository.create_dashboard(dashboard_data)
        print(response.data[0])
        return DashboardResponse(**response.data[0])


    #-- Método para actualizar el tema o el idioma asociado al dashboard
    async def update_dashboard(self, dashboard_id : UUID, update_data : dict):
        #Se verifica que el dashboard existe antes de intentar actualizarlo
        dashboard_exists = await self.repository.get_dashboard_by_id(dashboard_id)
        if not dashboard_exists.data:
            raise DatabaseError("No se ha encontrado el dashboard especificado.")
        response = await self.repository.update_dashboard(dashboard_id, update_data)
        return DashboardResponse(**response.data[0])


    #-- Método para eliminar el dashboard asignado al usuario, cuando este es eliminado
    async def delete_dashboard(self, dashboard_id : UUID):
        #Se verifica que el dashboard existe antes de intentar eliminarlo
        dashboard_exists = await self.repository.get_dashboard_by_id(dashboard_id)
        if not dashboard_exists.data:
            raise DatabaseError("No se ha encontrado el dashboard especificado.")
        return await self.repository.delete_dashboard(dashboard_id)
