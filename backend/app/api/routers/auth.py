from fastapi import APIRouter

from app.api.controllers.auth_controller import controlador_login_usuario, controlador_registrar_usuario
from app.schemas.auth_schema import DatosLogin, DatosRespuestaLogin, DatosRegistro

router = APIRouter(prefix="/api/auth", tags=["Auth"])

# ruta de registro de usuario
@router.post("/register", response_model=DatosRespuestaLogin, status_code=201)
def ruta_registrar_usuario(datos_registro: DatosRegistro):
    return controlador_registrar_usuario(datos_registro)

# ruta para login de usuario
@router.post("/login", response_model=DatosRespuestaLogin)
def ruta_login_usuario(datos_login: DatosLogin):
    return controlador_login_usuario(datos_login)
