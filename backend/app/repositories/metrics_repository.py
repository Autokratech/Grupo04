import hashlib
import uuid
from datetime import datetime, timezone
from app.database_sync import supabase

TABLA_AGENTES = "agents"
TABLA_METRICAS = "metrics"


def buscar_agente_por_hostname(hostname: str):
    respuesta = (
        supabase.table(TABLA_AGENTES)
        .select("id")
        .eq("hostname", hostname)
        .limit(1)
        .execute()
    )
    return respuesta.data[0] if respuesta.data else None


def crear_agente(hostname: str, type_id: int):
    agent_key = str(uuid.uuid4())
    api_key_hash = hashlib.sha256(agent_key.encode()).hexdigest()
    datos = {
        "hostname": hostname,
        "type_id": type_id,
        "agent_key": agent_key,
        "api_key_hash": api_key_hash,
        "active": True,
    }
    respuesta = supabase.table(TABLA_AGENTES).insert(datos).execute()
    return respuesta.data[0] if respuesta.data else None


def insertar_metrica(agent_id: str, resource_type: str, resource_name: str, meta: dict):
    datos = {
        "ts": datetime.now(timezone.utc).isoformat(),
        "metric_key": str(uuid.uuid4()),
        "agent_id": agent_id,
        "resource_type": resource_type,
        "resource_name": resource_name,
        "result": "ok",
        "meta": meta,
    }
    respuesta = supabase.table(TABLA_METRICAS).insert(datos).execute()
    return respuesta.data[0] if respuesta.data else None


def obtener_ultima_metrica_de_agente(agent_id: str):
    respuesta = (
        supabase.table(TABLA_METRICAS)
        .select("*")
        .eq("agent_id", agent_id)
        .order("ts", desc=True)
        .limit(1)
        .execute()
    )
    return respuesta.data[0] if respuesta.data else None


def listar_metricas_por_resource_type(resource_type: str):
    respuesta = (
        supabase.table(TABLA_METRICAS)
        .select("*")
        .eq("resource_type", resource_type)
        .order("ts", desc=True)
        .execute()
    )
    return respuesta.data or []


def listar_recursos_por_resource_type(resource_type: str):
    respuesta = (
        supabase.table(TABLA_METRICAS)
        .select("agent_id, resource_name")
        .eq("resource_type", resource_type)
        .execute()
    )
    if not respuesta.data:
        return []
    vistos = set()
    resultado = []
    for fila in respuesta.data:
        clave = (fila["agent_id"], fila["resource_name"])
        if clave not in vistos:
            vistos.add(clave)
            resultado.append(fila)
    return resultado
