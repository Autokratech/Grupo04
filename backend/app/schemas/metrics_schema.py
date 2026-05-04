from pydantic import BaseModel


class DatosReportarMetrica(BaseModel):
    hostname: str
    type_id: int = 1
    resource_type: str
    resource_name: str
    meta: dict


class RespuestaReporte(BaseModel):
    agent_id: str
    ok: bool


class RespuestaMetrica(BaseModel):
    ts: str
    agent_id: str
    resource_type: str
    resource_name: str
    result: str | None = None
    meta: dict | None = None


class RespuestaRecurso(BaseModel):
    agent_id: str
    resource_name: str
