from app.schemas.role_schema import DatosActualizarRol, DatosCrearRol
from app.services.roles_service import (
    servicio_actualizar_rol,
    servicio_asignar_permiso_a_rol,
    servicio_borrar_rol,
    servicio_buscar_rol_por_id,
    servicio_crear_rol,
    servicio_listar_permisos_de_rol,
    servicio_listar_roles,
    servicio_quitar_permiso_de_rol,
)

# devuelve la lista todos los roles, para la administracion de roles, si se hace en la App la gestión de usuarios.
def controlador_listar_roles():
    return servicio_listar_roles()

# busca un rol por id y lo devuelve, para la administracion de roles
def controlador_buscar_rol_por_id(id_rol: int):
    return servicio_buscar_rol_por_id(id_rol)

# crea un nuevo rol con los datos recibidos, para la administracion de roles.
def controlador_crear_rol(datos_rol: DatosCrearRol):
    return servicio_crear_rol(datos_rol)

# actualiza un rol con los datos recibidos y el id del rol a actualizar.
def controlador_actualizar_rol(id_rol: int, datos_rol: DatosActualizarRol):
    """Actualiza un rol."""
    return servicio_actualizar_rol(id_rol, datos_rol)

# borra un rol por id, si nadie lo esta usando, para la administracion de roles.
def controlador_borrar_rol(id_rol: int):
    """Borra un rol si nadie lo esta usando."""
    return servicio_borrar_rol(id_rol)

# lista los permisos de un rol, para la administracion de roles
def controlador_listar_permisos_de_rol(id_rol: int):
    """Lista los permisos de un rol."""
    return servicio_listar_permisos_de_rol(id_rol)

# asigna un permiso a un rol, para la administracion de roles
def controlador_asignar_permiso_a_rol(id_rol: int, id_permiso: int):
    """Asigna un permiso a un rol."""
    return servicio_asignar_permiso_a_rol(id_rol, id_permiso)

# quita un permiso de un rol, para la administracion de roles
def controlador_quitar_permiso_de_rol(id_rol: int, id_permiso: int):
    """Quita un permiso de un rol."""
    return servicio_quitar_permiso_de_rol(id_rol, id_permiso)
