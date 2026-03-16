from fastapi import HTTPException
from fastapi.responses import JSONResponse
from models.dashboard import Dashboard, DashboardTabsResponse

#TODO: Revisar si es necesaria la creación de una tabla dashboard, o con users + dashboard_tabs es suficiente. Depende de cómo lo queramos gestionar
#Si se va a almacenar el tema del usuario (común para todo el dashboard) u otros parámetros de configuración sí es necesario (probablemente lo sea)
#TODO: DRY: Centralizar manejo de excepciones/respuestas y normalizar respuestas/errores con pydantic
#TODO: Revisar si tiene sentido centralizar consultas (select, updates..) y simplemente pasarle los filtros. Abordar al revisar el diseño de las clases de los widgets / métricas
#TODO: Añadir validaciones de las entradas (verificar existencia previa, etc)


class DashboardService:
    
    #Máximo temporal de pestañas simultáneas por usuario para el dashboard //TODO: Revisar el máximo que manejaremos
    DASHBOARD_MAX_TABS = 9

    #Método para obtener el ID del dashboard asignado al usuario
    def get_dashboard(user_id : int, supabase):
        try:
            response = supabase.table('dashboard') \
                .select('dashboard_id') \
                .eq("user_id", user_id) \
                .execute() 
            
            dashboard_id = response.data[0]["dashboard_id"]
            return dashboard_id

        except HTTPException as e:
            raise HTTPException(status_code=500, detail=f"Se ha producido un error al intentar recuperar el dashboard del usuario {user_id}: {e}")


    #Método para obtener las pestañas del dashboard del usuario, ordenadas según su índice (para permitir su ordenación por parte del user)
    def get_dashboard_tabs(dashboard_id : int, supabase):
        try:
            response = supabase.table('dashboard_tab') \
                .select('dashboard_tab_id, dashboard_tab_name') \
                .eq("dashboard_id", dashboard_id) \
                .order("dashboard_tab_index") \
                .execute() 
            
            dashboard_tabs_by_id = {tab['dashboard_tab_id']: tab['dashboard_tab_name'] for tab in response.data}
            #TODO: Mover este return a un JSON, lo dejé así para unas pruebas y no lo he visto hasta que he ido a hacer el commit... =')
            return DashboardTabsResponse(data=dashboard_tabs_by_id)
        
        except HTTPException as e:
            raise HTTPException(status_code=500, detail=f"Se ha producido un error al intentar recuperar las pestañas del dashboard del usuario: {e}")


    #Método para crear un nuevo dashboard para el usuario recién añadido //Partiendo de la premisa de que ningún usuario puede NO tener un dashboard asignado, relación 1 <-> 1
    def create_dashboard(user_id : int, supabase):
        try:
            #Se verifica que el usuario especificado NO dispone de un dashboard antes de intentar crearlo
            has_dashboard = supabase.table('dashboard') \
            .select('dashboard_id') \
            .eq('user_id', user_id) \
            .execute()
            
            if has_dashboard.data:
                raise HTTPException(status_code=409, detail=f"El usuario especificado {user_id} ya dispone de un dashboard asignado")
        
            supabase.table('dashboard') \
                .insert({'user_id' : user_id}) \
                .execute() 
            return JSONResponse(status_code=201, content={"message": f"Se ha creado un nuevo dashboard para el usuario {user_id}"})
        
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido crear un dashboard para el usuario : {e}")


    #Método para añadir una nueva pestaña al dashboard del usuario
    def create_dashboard_tab(dashboard_id : int, dashboard_tab_name : str, supabase):
        try:
            response = supabase.table('dashboard_tab') \
                .select('dashboard_tab_index') \
                .eq("dashboard_id", dashboard_id) \
                .order("dashboard_tab_index", desc=True) \
                .limit(1) \
                .execute() 

            if not response.data or response.data[0]["dashboard_tab_index"] == 0:
                dashboard_tab_index = 1
            else:   
            #Se obtiene el valor más alto de las pestañas disponibles en el dashboard y se le agrega 1
                dashboard_tab_index = response.data[0]["dashboard_tab_index"] + 1

            if dashboard_tab_index > DashboardService.DASHBOARD_MAX_TABS:
                raise HTTPException(status_code=409, detail=f"Se ha alcanzado el número máximo de pestañas disponibles: {DashboardService.DASHBOARD_MAX_TABS}")

            supabase.table('dashboard_tab') \
                .insert({"dashboard_id" : dashboard_id, 
                         'dashboard_tab_name' : dashboard_tab_name, 
                         'dashboard_tab_index' : dashboard_tab_index}) \
                .execute() 
            return JSONResponse(status_code=201, content={"message": "La nueva pestaña se ha añadido correctamente."})
        
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido añadir una nueva pestaña en el dashboard del usuario: {e}")


    #TODO: Revisar si tiene sentido implementar esta funcionalidad, de momento esta tabla tiene dos campos user_id, dashboard_id, que no tiene sentido "actualizar" una vez asignados
    #Salvo que se añadan otros parámetros, como dashboard_theme, etc.
    def update_dashboard(dashboard_id : int, supabase):
        pass

    
    #Método para actualizar los parámetros de una pestaña del dashboard (fundametalmente: name e índex)
    def update_dashboard_tab(dashboard_tab_id : int, dashboard_tab_column : str, dashboard_tab_value : str, supabase):
        try:
            supabase.table('dashboard_tab') \
                .update({dashboard_tab_column : dashboard_tab_value}) \
                .eq("dashboard_tab_id", dashboard_tab_id) \
                .execute() 
            
            return JSONResponse(status_code=200, content={"message": "La pestaña se ha actualizado correctamente."})

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido actualizar el valor de {dashboard_tab_column}: {e}")


    #Método para eliminar el dashboard asignado al usuario, cuando este es eliminado
    def delete_dashboard(dashboard_id : int, supabase):
        try:
            #Antes de eliminar el dashboard es necesario eliminar todas las tabs que tengan referencias a éste
            dashboard_tabs = DashboardService.get_dashboard_tabs(dashboard_id, supabase)

            for tab_id in dashboard_tabs.data.keys():
                DashboardService.delete_dashboard_tab(tab_id, supabase)

            supabase.table('dashboard') \
                .delete() \
                .eq("dashboard_id", dashboard_id) \
                .execute() 
            return JSONResponse(status_code=200, content={"message": "El dashboard del usuario se ha eliminado correctamente."})

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido eliminar el dashboard del usuario: {e}")


    #Método para eliminar una o más tabs del dashboard seleccionado
    def delete_dashboard_tab(dashboard_tab_id : int, supabase):
        try:
            #Se verifica la existencia de la pestaña antes de intentar eliminarla
            dashboard_tab_exists = supabase.table('dashboard_tab') \
            .select('dashboard_tab_id') \
            .eq("dashboard_tab_id", dashboard_tab_id) \
            .execute()

            if not dashboard_tab_exists.data:
                raise HTTPException(status_code=404, detail=f"No se ha podido encontrar la pestaña especificada")
        
            supabase.table('dashboard_tab') \
                .delete() \
                .eq("dashboard_tab_id", dashboard_tab_id) \
                .execute() 
            return JSONResponse(status_code=200, content={"message": "La pestaña se ha eliminado correctamente"})

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido eliminar la pestaña con id {dashboard_tab_id} del dashboard: {e}")
        
