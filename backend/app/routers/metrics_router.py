from fastapi import APIRouter

from app.controllers.metrics_controller import (
    controlador_metricas_por_resource_type,
    controlador_recursos_por_resource_type,
    controlador_reportar_metrica,
    controlador_ultima_metrica,
)
from app.schemas.metrics_schema import (
    DatosReportarMetrica,
    RespuestaMetrica,
    RespuestaRecurso,
    RespuestaReporte,
)

router = APIRouter(prefix="/metrics", tags=["Metrics"])


@router.post("/report", response_model=RespuestaReporte, status_code=201)
def ruta_reportar_metrica(datos: DatosReportarMetrica):
    return controlador_reportar_metrica(datos)


@router.get("/agent/{agent_id}/latest", response_model=RespuestaMetrica)
def ruta_ultima_metrica(agent_id: str):
    return controlador_ultima_metrica(agent_id)


@router.get("/resource-type/{resource_type}", response_model=list[RespuestaMetrica])
def ruta_metricas_por_resource_type(resource_type: str):
    return controlador_metricas_por_resource_type(resource_type)


@router.get("/resource-type/{resource_type}/resources", response_model=list[RespuestaRecurso])
def ruta_recursos_por_resource_type(resource_type: str):
    return controlador_recursos_por_resource_type(resource_type)
