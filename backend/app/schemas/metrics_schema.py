from pydantic import BaseModel
from typing import Any


class DatosReportarMetrica(BaseModel):
    agent_name: str
    agent_os: str
    provider_name: str
    agent_data: dict[str, Any]


class RespuestaReporte(BaseModel):
    agent_id: str
    ok: bool


class RespuestaMetrica(BaseModel):
    agent_id: str
    agent_data: dict[str, Any]
    created_at: str


class RespuestaRecurso(BaseModel):
    agent_id: str
