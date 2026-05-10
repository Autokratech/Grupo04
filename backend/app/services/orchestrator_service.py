import asyncio
from app.providers.provider_factory import ProviderFactory
from app.repositories.interfaces.orchestrator_interface import IOrchestratorRepository
from fastapi.sse import EventSourceResponse, ServerSentEvent
from app.models.orchestrator_model import *
from app.schemas.orchestrator_schema import *
from datetime import datetime, timezone
from uuid import UUID

'''
    Punto de acceso de la API para la consulta de métricas y ejecución de operaciones sobre los diferentes
    providers, disponibles en /providers

    Todo lo que tenga que ver con las métricas y datos de providers externos (agentes, providers de git, 
    providers de cloud...) pasa por aquí. 

'''

class OrchestratorService:
    pass

    def __init__(self, repository: IOrchestratorRepository, factory: ProviderFactory):
        self.repository = repository
        self.factory = factory

    
    # Step 1 -- Frontend envía el ID de la pestaña activa: tab_id
    async def orchestate_user_tab(self, user_id : UUID, tab_id : UUID):
        
        # Step 2 -- Se obtienen los widgets configurados en la pestaña
        widgets_list = await self.get_active_tab_widgets(tab_id)

        # Step 3 -- Se extraen los campos para la prerenderización de los widgets y generar las peticiones de los providers
        widgets_skeleton_params, data_request_params = await self.split_widgets_data(widgets_list)

        # Step 4 -- Se envía un primer compendio de datos para que el front vaya renderizando los widgets
        print(f"Datos renderización: {widgets_skeleton_params}")
        yield {
            "event" : "widgets_skeleton",
            "data" : widgets_skeleton_params.model_dump()
        }

        
        print(f"data source params is {type(data_request_params)}")
        #TODO: Mejoras, si mismo provider reutilizar token de caché

        aggregated_response = [] 
        # Step 5 -- Se envían los datos a la factory of factories para que devuelva la instancia concreta a utilizar 
        # Step 6 -- Se pasan los parámetros concretos a la instancia creada en el paso anterior
        # En este punto la obtención de la métrica y la normalización del resultado del provider pasará a ser tarea interna del provider
        tasks = [self.fetch_tab_widget_data(user_id, request, aggregated_response)
                for request in data_request_params.providers]
        
        await asyncio.gather(*tasks, return_exceptions=True)
        # TODO: Añadir timeout y derivar la consulta al caché, y en caso de que tampoco haya datos, enviar "None" / "No data available", o {} al front

        widgets_data_params = TabWidgetDataList(tab_widgets_data=aggregated_response)

        yield {
            "event" : "widgets_data",
            "data" : widgets_data_params.model_dump()
        }


    # -- Método para obtener los widgets activos en la pestaña seleccionada
    async def get_active_tab_widgets(self, tab_id : int):
        response = await self.repository.get_active_tab_widgets(tab_id)
        print(response.data)
        widgets_list = [TabWidget(**widget) for widget in response.data]
        return widgets_list


    # -- Método para dividir los datos de los widgets en dos bloques: datos para enviar al front en el primer stream y datos para hacer la request
    async def split_widgets_data(self, widgets_list):
        widgets_skeleton_params = [TabWidgetSkeleton(**widget.model_dump()) for widget in widgets_list]
        data_request_params = [ProviderData(**widget.model_dump()) for widget in widgets_list]
        return TabWidgeSkeletontList(tab_widgets=widgets_skeleton_params), ProviderRequestList(providers=data_request_params)


    # -- Método para obtener las métricas del provider deseado
    async def fetch_tab_widget_data(self, user_id, request : ProviderData, aggregated_response : list):
        try:
            provider_instance = await self.factory.create_provider_instance(user_id, request.provider_name)
            provider_response = await provider_instance.fetch_provider_data(request.data_type, request.custom_config)
            standarized_response = await self.standarize_response(request, Data(**provider_response))

            aggregated_response.append(standarized_response)
        except Exception as e:
            print(f"Se ha producido un error al intentar acceder a los datos de {request.data_type} del provider {request.provider_name} : {e}")
            aggregated_response.append(TabWidgetData(tab_widget_id = request.tab_widget_id,
                                                          provider_tag = request.provider_name,
                                                          status = "error"))


    async def standarize_response(self, request : ProviderData , response_data : Data):
        status = "success" if response_data.count else "error"
        timestamp = datetime.now(timezone.utc).isoformat()
        standarized_response = TabWidgetData(tab_widget_id = request.tab_widget_id,
                                            provider_tag = request.provider_name,
                                            status = status,
                                            timestamp = timestamp,
                                            ttl = 300, #Hardcodeado para pruebas, pero debería venir del data_type )
                                            data=response_data)
        return standarized_response


    #-- Método para vincular un nuevo widget con la pestaña activa
    async def add_widget_to_active_tab(self, tab_id : UUID, tab_widget_data: dict):
        tab_widget_data.update({"tab_id" : str(tab_id)})
        response = await self.repository.add_widget_to_active_tab(tab_widget_data)
        return AddTabWidgetResponse(**response.data[0])


    #-- Método para ejecutar la acción de un widget de tipo action (o híbrido, si al final disponemos de híbridos también)
    # TODO: Enlazarlo con la parte de auditoría para que 1 acción = 1 registro (salvo que más adelante estimemos auditar sólo algunas)
    async def execute_tab_widget_action(self, widget_data):
        pass