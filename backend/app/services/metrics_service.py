from fastapi import HTTPException
from app.repositories import metrics_repository
from app.schemas.metrics_schema import DatosReportarMetrica


def servicio_reportar_metrica(datos: DatosReportarMetrica):
    agente = metrics_repository.buscar_agente_por_nombre(datos.agent_name)
    if not agente:
        agente = metrics_repository.crear_agente(datos.agent_name, datos.agent_os, datos.provider_name)

    metrics_repository.insertar_metrica(agente["agent_id"], datos.agent_data)
    return {"agent_id": agente["agent_id"], "ok": True}


def servicio_ultima_metrica(agent_id: str):
    metrica = metrics_repository.obtener_ultima_metrica_de_agente(agent_id)
    if not metrica:
        raise HTTPException(status_code=404, detail="Sin métricas para este agente")
    return metrica


def servicio_metricas_por_resource_type(resource_type: str):
    return metrics_repository.listar_metricas_por_resource_type(resource_type)


def servicio_recursos_por_resource_type(resource_type: str):
    return metrics_repository.listar_recursos_por_resource_type(resource_type)
