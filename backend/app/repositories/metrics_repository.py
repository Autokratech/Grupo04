from app.database_sync import supabase

TABLA_AGENTES = "agents"
TABLA_METRICAS = "agent_metrics"


def buscar_agente_por_nombre(agent_name: str):
    respuesta = (
        supabase.table(TABLA_AGENTES)
        .select("agent_id, provider_name")
        .eq("agent_name", agent_name)
        .limit(1)
        .execute()
    )
    return respuesta.data[0] if respuesta.data else None


def crear_agente(agent_name: str, agent_os: str, provider_name: str):
    datos = {
        "agent_name": agent_name,
        "agent_os": agent_os,
        "provider_name": provider_name,
    }
    respuesta = supabase.table(TABLA_AGENTES).insert(datos).execute()
    return respuesta.data[0] if respuesta.data else None


def insertar_metrica(agent_id: str, agent_data: dict):
    datos = {
        "agent_id": agent_id,
        "agent_data": agent_data,
    }
    respuesta = supabase.table(TABLA_METRICAS).insert(datos).execute()
    return respuesta.data[0] if respuesta.data else None


def obtener_ultima_metrica_de_agente(agent_id: str):
    respuesta = (
        supabase.table(TABLA_METRICAS)
        .select("*")
        .eq("agent_id", agent_id)
        .order("created_at", desc=True)
        .limit(1)
        .execute()
    )
    return respuesta.data[0] if respuesta.data else None


def listar_metricas_por_resource_type(resource_type: str):
    respuesta = (
        supabase.table(TABLA_METRICAS)
        .select("*")
        .filter("agent_data->>resource_type", "eq", resource_type)
        .order("created_at", desc=True)
        .execute()
    )
    return respuesta.data or []


def listar_metricas_por_resource_type_y_tipo_agente(resource_type: str, provider_name: str):
    agentes = (
        supabase.table(TABLA_AGENTES)
        .select("agent_id")
        .eq("provider_name", provider_name)
        .execute()
    )
    if not agentes.data:
        return []

    agent_ids = [a["agent_id"] for a in agentes.data]

    respuesta = (
        supabase.table(TABLA_METRICAS)
        .select("*")
        .filter("agent_data->>resource_type", "eq", resource_type)
        .in_("agent_id", agent_ids)
        .order("created_at", desc=True)
        .execute()
    )
    return respuesta.data or []


def listar_recursos_por_resource_type(resource_type: str):
    respuesta = (
        supabase.table(TABLA_METRICAS)
        .select("agent_id, agent_data")
        .filter("agent_data->>resource_type", "eq", resource_type)
        .execute()
    )
    if not respuesta.data:
        return []
    vistos = set()
    resultado = []
    for fila in respuesta.data:
        agent_id = fila["agent_id"]
        if agent_id not in vistos:
            vistos.add(agent_id)
            resultado.append({"agent_id": agent_id})
    return resultado
