from fastapi import HTTPException
from fastapi.responses import JSONResponse
from core.providers.provider_factory import ProviderFactory
from .widget_service import WidgetService


'''
    Punto de acceso de la API para la consulta de métricas y ejecución de operaciones sobre los diferentes
    providers, disponibles en /core/providers

    Todo lo que tenga que ver con las métricas y datos de providers externos (agentes, providers de git, 
    providers de cloud...) pasa por aquí. 

'''
class OrchestratorService:
    pass