from pydantic import BaseModel


class RespuestaMensaje(BaseModel):
    mensaje: str


class DatosCrearRol(BaseModel):
    name: str
    description: str | None = None


class DatosActualizarRol(BaseModel):
    name: str | None = None
    description: str | None = None


class RespuestaRol(BaseModel):
    id: int
    name: str
    description: str | None = None
