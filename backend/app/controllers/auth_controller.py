from app.schemas.auth_schema import DatosLogin, DatosRegistro
from app.services.auth_service import servicio_login_usuario, servicio_registrar_usuario
#TODO: Debo de agregar valicaciones antes de pasarlo al servicio como medida extra

# Recibe el registro y se lo pasa al servicio
def controlador_registrar_usuario(datos_registro: DatosRegistro):
    return servicio_registrar_usuario(datos_registro)

# Recibe el login y se lo pasa al servicio
def controlador_login_usuario(datos_login: DatosLogin):
    return servicio_login_usuario(datos_login)
