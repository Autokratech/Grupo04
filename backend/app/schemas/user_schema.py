from pydantic import BaseModel, EmailStr


class RespuestaMensaje(BaseModel):
    mensaje: str


class DatosCrearUsuario(BaseModel):
    email: EmailStr
    password: str
    role_id: int | None = 1
    active: bool = True


class DatosActualizarUsuario(BaseModel):
    email: EmailStr | None = None
    password: str | None = None
    role_id: int | None = None
    active: bool | None = None


class RespuestaUsuario(BaseModel):
    id: str
    email: EmailStr
    role_id: int
    active: bool
    created_at: str
