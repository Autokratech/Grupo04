from fastapi import HTTPException
from app.repositories import metrics_repository
from app.schemas.metrics_schema import DatosReportarMetrica


def servicio_reportar_metrica(datos: DatosReportarMetrica):
    agente = metrics_repository.buscar_agente_por_hostname(datos.hostname)
    if not agente:
        agente = metrics_repository.crear_agente(datos.hostname, datos.type_id)

    metrics_repository.insertar_metrica(
        agent_id=agente["id"],
        resource_type=datos.resource_type,
        resource_name=datos.resource_name,
        meta=datos.meta,
    )
    return {"agent_id": agente["id"], "ok": True}


def servicio_ultima_metrica(agent_id: str):
    metrica = metrics_repository.obtener_ultima_metrica_de_agente(agent_id)
    if not metrica:
        raise HTTPException(status_code=404, detail="Sin métricas para este agente")
    return metrica


def servicio_metricas_por_resource_type(resource_type: str):
    return metrics_repository.listar_metricas_por_resource_type(resource_type)


def servicio_recursos_por_resource_type(resource_type: str):
    return metrics_repository.listar_recursos_por_resource_type(resource_type)
