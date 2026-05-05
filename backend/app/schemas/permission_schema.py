from pydantic import BaseModel


class RespuestaMensaje(BaseModel):
    mensaje: str


class DatosCrearPermiso(BaseModel):
    code: str
    name: str
    description: str | None = None


class DatosActualizarPermiso(BaseModel):
    code: str | None = None
    name: str | None = None
    description: str | None = None


class RespuestaPermiso(BaseModel):
    id: int
    code: str
    name: str
    description: str | None = None
