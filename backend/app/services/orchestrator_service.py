from fastapi import HTTPException
from fastapi.responses import JSONResponse
from app.providers.provider_factory import ProviderFactory
from app.repositories.interfaces.orchestrator_interface import IOrchestratorRepository
from app.models.orchestrator_model import *

'''
    Punto de acceso de la API para la consulta de métricas y ejecución de operaciones sobre los diferentes
    providers, disponibles en /providers

    Todo lo que tenga que ver con las métricas y datos de providers externos (agentes, providers de git, 
    providers de cloud...) pasa por aquí. 

'''

#TODO: Implementar SSE para enviar primero los widgets y después los datos
# Revisar más tarde: https://fastapi.tiangolo.com/tutorial/server-sent-events/

class OrchestratorService:
    pass

    def __init__(self, repository: IOrchestratorRepository, factory: ProviderFactory):
        self.repository = repository
        self.factory = factory

    # Step 0 -- Autenticación del usuario (pendiente de integración con el código de esa parte)
    # Step 1 -- Frontend envía el ID de la pestaña activa: tab_id
    
    async def orchestate_user_tab(self, tab_id : int):
        
        # Step 2 -- Se obtienen los widgets configurados en la pestaña
        widgets_list = await self.get_active_tab_widgets(tab_id)

        # Step 3 -- Se extraen los campos para la prerenderización de los widgets y generar las peticiones de los providers
        widgets_render_data, data_source_params = await self.split_widgets_data(widgets_list)

        # Step 4 -- Se envía un primer compendio de datos para que el front vaya renderizando los widgets
        #TODO: Implementar SSE
        print(f"Datos renderización: {widgets_render_data}")

        # Step 5 -- Se envían los datos a la factory of factories para que devuelva la instancia concreta a utilizar
        for key in data_source_params.keys():
            provider_name = data_source_params[key]["source_provider"]
            if provider_name is not None:
                provider_instance = await self.factory.create_provider_instance(provider_name)
                print(provider_instance.__class__)
        
        # Step 6 -- Se pasan los parámetros concretos a la instancia creada en el paso anterior
        # Nota --> Aquí habrá que ver cuánto se puede generalizar la abstracción de dichos datos
        # En este punto la obtención de la métrica y la normalización del resultado del provider pasará a ser tarea interna del provider
        # TODO: Investigar cómo implementar todo este flujo de manera asíncrona, para que las llamadas se realicen en paralelo a todos los providers: asyncio?
        # widgets_data = self.fetch_tab_widgets_data(data_source_params)
        return ({"data_source_params" : data_source_params})



    # -- Método para obtener los widgets activos en la pestaña seleccionada
    async def get_active_tab_widgets(self, tab_id : int):
        response = await self.repository.get_active_tab_widgets(tab_id)
        widgets_list = [TabWidget(**widget) for widget in response.data]
        return widgets_list


    # -- Método para dividir los datos de los widgets en dos bloques: datos intrínsecos del widget y datos de la métrica
    # Nota: pendiente buscar un mejor nombre para el método -- nombre provisional
    async def split_widgets_data(self, widgets_list):
        widget_render_data = { "widgets" : {} }
        data_source_params = {}

        for widget in widgets_list:
            widget_render_data["widgets"][f"tab_widget_{widget.tab_widget_id}"] = widget.widgets

            if all(widget.provider_name and widget.data_type) is not None:
                data_source_params.update({ 
                    f"tab_widget_{widget.tab_widget_id}" : {"source_provider" : widget.provider_name,
                                                            "data_type"    : widget.data_type,
                                                            "custom_config" : widget.custom_config }})
        return widget_render_data, data_source_params
        

    # -- Método para obtener las métricas del provider deseado
    async def fetch_tab_widgets_data(self, provider_instance, data_source_params):
        pass
    
    # -- Método para ejecutar la acción de un widget de tipo action (o híbrido, si al final disponemos de híbridos también)
    # TODO: Enlazarlo con la parte de auditoría para que 1 acción = 1 registro (salvo que más adelante estimemos auditar sólo algunas)
    async def execute_tab_widget_action(self, widget_data):
        pass

