from fastapi import HTTPException
from fastapi.responses import JSONResponse

#TODO: (Más bien In progress) --> Centralizar, catalogar y mejorar gestión de errores, y trasladar llamadas a la BBDD a repositories

class WidgetService:

    WIDGETS_TABLE_NAME="widgets"
    DASHBOARD_TAB_WIDGETS_TABLE_NAME="dashboard_tabs_widgets" #Tabla intermedia para asociar widgets + pestaña del dashboard

    #TODO: Separar columnas disponibles de columnas actualizables (update_widget no debería cambiar el widget_id, por ejemplo)
    #TODO: Implementar la obtención de las columnas disponibles directamente desde el schema de la BBDD, y generar dos listas (actualizables y no actualizables)
    AVAILABLE_WIDGETS_COLUMNS = ["widget_id", "widget_name", "widget_description", "widget_type", "data_type"]
    AVAILABLE_DASHBOARD_TABS_WIDGETS_COLUMNS = ["widget_id", "dashboard_tab_id", "metric_name", "provider_type", "provider_name"]


    #Método genérico para recuperar un widget concreto -- Puede ser útil para expandir información sobre el widget en alguna opción de la app
    @staticmethod
    def get_widget(widget_id : int, supabase):
        try:
            response = supabase.table(WidgetService.WIDGETS_TABLE_NAME) \
                .select('*') \
                .eq("widget_id", widget_id) \
                .limit(1) \
                .execute() 
            return response
        
        except Exception as e:
                raise HTTPException(status_code=400, detail=f"Se ha producido un error al recuperar el widget {widget_id}: {e}")


    #Método para recuperar todos los widgets en base al filtro especificado
    #Es el método que se invocará desde el catálogo para listar todos los disponibles 
    @staticmethod
    def get_all_widgets(widget_filters: dict, supabase):
        if any(filter_key not in WidgetService.AVAILABLE_WIDGETS_COLUMNS for filter_key in widget_filters):
            raise HTTPException(status_code=400, detail=f"Se ha proporcionado un filtro inválido. Los filtros disponibles son: {WidgetService.AVAILABLE_WIDGETS_COLUMNS}")
        try:
            response = supabase.table(WidgetService.WIDGETS_TABLE_NAME) \
                    .select('*') \
                    .match(widget_filters) \
                    .execute() 
            return response
        
        except Exception as e:
                raise HTTPException(status_code=400, detail=f"Se ha producido un error al recuperar los widgets: {e}")


    #Método para recuperar todos los widgets de una pestaña
    #Es el método que se invocará desde el dashboard para obtener todos los widgets de cada pestaña
    #También se invocará desde el orchestrator para obtener los datos de los widgets activos de la pestaña y consultar las métricas asociadas
    @staticmethod
    def get_all_tab_widgets(dashboard_tab_id : int, supabase):
        try:
            response = supabase.table(WidgetService.DASHBOARD_TAB_WIDGETS_TABLE_NAME) \
                .select('*') \
                .eq("dashboard_tab_id", dashboard_tab_id) \
                .execute() 
            return response
        
        except Exception as e:
                raise HTTPException(status_code=400, detail=f"Se ha producido un error al recuperar los widgets de la pestaña {dashboard_tab_id}: {e}")
    

    #Método para crear un nuevo widget
    @staticmethod
    def create_widget(widget_data : dict, supabase):
        if any(filter_key not in WidgetService.AVAILABLE_WIDGETS_COLUMNS for filter_key in widget_data):
            raise HTTPException(status_code=400, detail=f"Se ha proporcionado un dato inválido. Las columnas disponibles son: {WidgetService.AVAILABLE_WIDGETS_COLUMNS}")
        #TODO: Añadir validación para comprobar que los valores obligatorios se encuentran en el cuerpo de la query antes de lanzar la petición
        try:
            response = supabase.table(WidgetService.WIDGETS_TABLE_NAME) \
                        .insert(widget_data) \
                        .execute()
            
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido crear el widget: {e}")

        if not response.data:
            raise HTTPException(status_code=404, detail="Se ha producido un error al realizar la solicitud a la base de datos.")
        return JSONResponse(status_code=201, content={"message": "El widget se ha creado correctamente."})


    #Método para añadir un nuevo widget a la pestaña del dashboard
    @staticmethod
    def add_tab_widget(widget_data : dict, supabase):
        if any(filter_key not in WidgetService.AVAILABLE_DASHBOARD_TABS_WIDGETS_COLUMNS for filter_key in widget_data):
            raise HTTPException(status_code=400, detail=f"Se ha proporcionado un dato inválido. Las columnas disponibles son: {WidgetService.AVAILABLE_DASHBOARD_TABS_WIDGETS_COLUMNS}")
        #TODO: Añadir validación para comprobar que los valores obligatorios se encuentran en el cuerpo de la query antes de lanzar la petición
        try:
            response = supabase.table(WidgetService.DASHBOARD_TAB_WIDGETS_TABLE_NAME) \
                    .insert(widget_data) \
                    .execute()
            
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido añadir el widget: {e}")
        
        if not response.data:
            raise HTTPException(status_code=404, detail="Se ha producido un error al realizar la solicitud a la base de datos.")
        return JSONResponse(status_code=201, content={"message": f"El widget se ha añadido correctamente."})
        



    #Método para cambiar el valor de un widget
    @staticmethod
    def update_widget(widget_id : int, widget_column : str, widget_value, supabase):
        if widget_column not in WidgetService.AVAILABLE_WIDGETS_COLUMNS:
            raise HTTPException(status_code=400, detail=f"Se ha proporcionado un valor inválido para la columna. Las columnas disponibles son: {WidgetService.AVAILABLE_WIDGETS_COLUMNS}")
        try:
            response = supabase.table(WidgetService.WIDGETS_TABLE_NAME) \
                    .update({widget_column : widget_value}) \
                    .eq("widget_id", widget_id) \
                    .execute() 
        
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido actualizar el valor del widget {widget_id}: {e}")
        
        if not response.data:
            raise HTTPException(status_code=404, detail="Se ha producido un error al realizar la solicitud a la base de datos.")
        return JSONResponse(status_code=200, content={"message": f"El widget {widget_id} se ha actualizado correctamente."})


    #Método para cambiar el valor de un widget 
    #Es el método que se invocará para añadir un nuevo item a una pestaña concreta
    @staticmethod
    def update_tab_widget(widget_id : int, dashboard_tab_id : int, widget_column : str, widget_value, supabase):
        if widget_column not in WidgetService.AVAILABLE_DASHBOARD_TABS_WIDGETS_COLUMNS:
            raise HTTPException(status_code=400, detail=f"Se ha proporcionado un valor inválido para la columna. Las columnas disponibles son: {WidgetService.AVAILABLE_DASHBOARD_TABS_WIDGETS_COLUMNS}")
        try:
            response = supabase.table(WidgetService.DASHBOARD_TAB_WIDGETS_TABLE_NAME) \
                    .update({widget_column : widget_value}) \
                    .match({"widget_id" : widget_id, "dashboard_tab_id" : dashboard_tab_id}) \
                    .execute()    

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido actualizar el valor del widget {widget_id} de la pestaña {dashboard_tab_id}: {e}")
        
        if not response.data:
            raise HTTPException(status_code=404, detail="Se ha producido un error al realizar la solicitud a la base de datos.")
        return JSONResponse(status_code=200, content={"message": f"El widget {widget_id} de la pestaña {dashboard_tab_id} se ha actualizado correctamente."})


    #Metodo para eliminar un widget del listado general (por deprecación del mismo)
    @staticmethod
    def delete_widget(widget_id : int, supabase):
        try:
            response = supabase.table(WidgetService.WIDGETS_TABLE_NAME) \
                               .delete() \
                               .eq("widget_id", widget_id) \
                               .execute()

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido eliminar el widget {widget_id}: {e}")         
        
        if not response.data:
            raise HTTPException(status_code=404, detail="Se ha producido un error al realizar la solicitud a la base de datos.")
        return JSONResponse(status_code=200, content={"message": f"El widget {widget_id} se ha eliminado correctamente."})

    #Método para eliminar el widget de una pestaña
    #Es el método que se invocará para eliminar el widget de una pestaña del dashboard
    @staticmethod
    def delete_tab_widget(widget_id : int, dashboard_tab_id : int, supabase):
        try:
            response = supabase.table(WidgetService.DASHBOARD_TAB_WIDGETS_TABLE_NAME) \
                               .delete() \
                               .match({"widget_id" : widget_id, "dashboard_tab_id" : dashboard_tab_id}) \
                               .execute()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"No se ha podido eliminar el widget {widget_id} de la pestaña {dashboard_tab_id}: {e}")         

        if not response.data:
            raise HTTPException(status_code=404, detail="Se ha producido un error al realizar la solicitud a la base de datos.")
        return JSONResponse(status_code=200, content={"message": f"El widget {widget_id} se ha eliminado correctamente de la pestaña {dashboard_tab_id}."})
