from app.repositories.interfaces.dashboard_interface import IDashboardRepository
from app.schemas.dashboard_schema import *
from app.core.exceptions import DatabaseError

class DashboardService:

    def __init__(self, repository: IDashboardRepository):
        self.repository = repository


    #Método para obtener el ID del dashboard asignado al usuario
    async def get_user_dashboard(self, user_id : int):
        response = await self.repository.get_user_dashboard(user_id)
        if not response.data:
            raise DatabaseError("No se encontró el dashboard del usuario.")
        return DashboardResponse(**response.data[0])


    #Método para crear un nuevo dashboard para el usuario recién añadido: 
    async def create_dashboard(self, dashboard_data : dict):
        #Se verifica que el usuario especificado NO dispone de un dashboard antes de intentar crearlo
        has_dashboard = await self.repository.get_user_dashboard(dashboard_data["user_id"])
        if has_dashboard.data:
            raise DatabaseError("El usuario ya dispone de un dashboard asignado.")
        
        return await self.repository.create_dashboard(dashboard_data)


    #Método para actualizar el tema del dashboard
    async def update_dashboard(self, dashboard_id : int, dashboard_theme : str):
        return await self.repository.update_dashboard_theme(dashboard_id, dashboard_theme)


    #Método para eliminar el dashboard asignado al usuario, cuando este es eliminado
    async def delete_dashboard(self, dashboard_id : int):
        return await self.repository.delete_dashboard(dashboard_id)

