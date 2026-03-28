from app.schemas.user_schema import DatosCrearUsuario, DatosActualizarUsuario
from app.services.users_service import (
    servicio_actualizar_usuario,
    servicio_borrar_usuario,
    servicio_buscar_usuario_por_id,
    servicio_crear_usuario,
    servicio_listar_usuarios,
)

# Drevuelve la lista de usuarios, con un filtro opcional para mostrar solo los activos o inactivos.
def controlador_listar_usuarios(filtro_activo: bool | None = None):
    return servicio_listar_usuarios(filtro_activo)

# busca un usuario por su id y lo devuelve
def controlador_buscar_usuario_por_id(id_usuario: str):
    return servicio_buscar_usuario_por_id(id_usuario)

# crea un nuevo usuario con los datos recibidos
def controlador_crear_usuario(datos_usuario: DatosCrearUsuario):
    return servicio_crear_usuario(datos_usuario)

# actualiza un usuario con los datos recibidos y el id del usuario a actualizar
def controlador_actualizar_usuario(id_usuario: str, datos_usuario: DatosActualizarUsuario):
    return servicio_actualizar_usuario(id_usuario, datos_usuario)

# borra un usuario por su id, si nadie lo esta usando, para la administracion de usuarios.
def controlador_borrar_usuario(id_usuario: str):
    return servicio_borrar_usuario(id_usuario)
