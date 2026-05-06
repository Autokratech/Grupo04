from pydantic import BaseModel, EmailStr


class DatosRegistro(BaseModel):
    email: EmailStr
    password: str


class DatosLogin(BaseModel):
    email: EmailStr
    password: str


class DatosUsuarioToken(BaseModel):
    id: str
    email: EmailStr
    role_id: int
    active: bool
    created_at: str


class DatosRespuestaLogin(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: DatosUsuarioToken
