from app.schemas.metrics_schema import DatosReportarMetrica
from app.services.metrics_service import (
    servicio_metricas_por_resource_type,
    servicio_recursos_por_resource_type,
    servicio_reportar_metrica,
    servicio_ultima_metrica,
)


def controlador_reportar_metrica(datos: DatosReportarMetrica):
    return servicio_reportar_metrica(datos)


def controlador_ultima_metrica(agent_id: str):
    return servicio_ultima_metrica(agent_id)


def controlador_metricas_por_resource_type(resource_type: str):
    return servicio_metricas_por_resource_type(resource_type)


def controlador_recursos_por_resource_type(resource_type: str):
    return servicio_recursos_por_resource_type(resource_type)
