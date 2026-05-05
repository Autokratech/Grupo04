from fastapi import APIRouter, Depends

from app.controllers.roles_controller import (
    controlador_actualizar_rol,
    controlador_asignar_permiso_a_rol,
    controlador_borrar_rol,
    controlador_buscar_rol_por_id,
    controlador_crear_rol,
    controlador_listar_permisos_de_rol,
    controlador_listar_roles,
    controlador_quitar_permiso_de_rol,
)
from app.schemas.permission_schema import RespuestaPermiso
from app.schemas.role_schema import DatosActualizarRol, DatosCrearRol, RespuestaMensaje, RespuestaRol
from app.core.guardias import pedir_permiso

router = APIRouter(prefix="/roles", tags=["Roles"])

# ruta para listar todos los roles
@router.get("/", response_model=list[RespuestaRol])
def ruta_listar_roles(usuario_actual=Depends(pedir_permiso("roles.read"))):
    return controlador_listar_roles()

# ruta para buscar un rol por el id
@router.get("/{id_rol}", response_model=RespuestaRol)
def ruta_buscar_rol_por_id(id_rol: int, usuario_actual=Depends(pedir_permiso("roles.read"))):
    return controlador_buscar_rol_por_id(id_rol)

# ruta para crear un nuevo rol
@router.post("/", response_model=RespuestaRol, status_code=201)
def ruta_crear_rol(datos_rol: DatosCrearRol, usuario_actual=Depends(pedir_permiso("roles.create"))):
    return controlador_crear_rol(datos_rol)

# ruta para actualizar un rol
@router.put("/{id_rol}", response_model=RespuestaRol)
def ruta_actualizar_rol(id_rol: int, datos_rol: DatosActualizarRol, usuario_actual=Depends(pedir_permiso("roles.update"))):

    return controlador_actualizar_rol(id_rol, datos_rol)

# ruta para borrar un rol
@router.delete("/{id_rol}", response_model=RespuestaMensaje)
def ruta_borrar_rol(id_rol: int, usuario_actual=Depends(pedir_permiso("roles.delete"))):
  
    return controlador_borrar_rol(id_rol)

# ruta para listar los permisos de rol
@router.get("/{id_rol}/permissions", response_model=list[RespuestaPermiso])
def ruta_listar_permisos_de_rol(id_rol: int, usuario_actual=Depends(pedir_permiso("roles.read"))):
    return controlador_listar_permisos_de_rol(id_rol)

# ruta para asignar permisos a un rol
@router.post("/{id_rol}/permissions/{id_permiso}", response_model=RespuestaMensaje)
def ruta_asignar_permiso_a_rol(
    id_rol: int,
    id_permiso: int,
    usuario_actual=Depends(pedir_permiso("roles.assign_permissions")),
):
    return controlador_asignar_permiso_a_rol(id_rol, id_permiso)

# ruta para quitar permiso de un rol
@router.delete("/{id_rol}/permissions/{id_permiso}", response_model=RespuestaMensaje)
def ruta_quitar_permiso_de_rol(
    id_rol: int,
    id_permiso: int,
    usuario_actual=Depends(pedir_permiso("roles.assign_permissions")),
):

    return controlador_quitar_permiso_de_rol(id_rol, id_permiso)
