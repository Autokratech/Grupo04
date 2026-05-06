from app.schemas.permission_schema import DatosActualizarPermiso, DatosCrearPermiso
from app.services.permissions_service import (
    servicio_actualizar_permiso,
    servicio_borrar_permiso,
    servicio_buscar_permiso_por_id,
    servicio_crear_permiso,
    servicio_listar_permisos,
)

# devuelve todos los permisos
def controlador_listar_permisos():
    return servicio_listar_permisos()

# busca un permiso por id y lo devuelve
def controlador_buscar_permiso_por_id(id_permiso: int):
    return servicio_buscar_permiso_por_id(id_permiso)

# crea un nuevo permiso con los datos recibidos
def controlador_crear_permiso(datos_permiso: DatosCrearPermiso):
    return servicio_crear_permiso(datos_permiso)

# actualiza un permiso con los datos recibidos y el id del permiso a actualizar
def controlador_actualizar_permiso(id_permiso: int, datos_permiso: DatosActualizarPermiso):
    return servicio_actualizar_permiso(id_permiso, datos_permiso)

# borra un permiso por id
def controlador_borrar_permiso(id_permiso: int):
    return servicio_borrar_permiso(id_permiso)
