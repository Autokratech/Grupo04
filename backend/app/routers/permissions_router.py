from fastapi import APIRouter, Depends

from app.controllers.permissions_controller import (
    controlador_actualizar_permiso,
    controlador_borrar_permiso,
    controlador_buscar_permiso_por_id,
    controlador_crear_permiso,
    controlador_listar_permisos,
)
from app.schemas.permission_schema import (
    DatosActualizarPermiso,
    DatosCrearPermiso,
    RespuestaMensaje,
    RespuestaPermiso,
)
from app.guardias import pedir_permiso

router = APIRouter(prefix="/permissions", tags=["Permissions"])

# ruta para la lista de permisos
@router.get("/", response_model=list[RespuestaPermiso])
def ruta_listar_permisos(usuario_actual=Depends(pedir_permiso("permissions.read"))):
    return controlador_listar_permisos()

# ruta para buscar un permiso por id
@router.get("/{id_permiso}", response_model=RespuestaPermiso)
def ruta_buscar_permiso_por_id(id_permiso: int, usuario_actual=Depends(pedir_permiso("permissions.read"))):
    return controlador_buscar_permiso_por_id(id_permiso)

# ruta para crear un permiso
@router.post("/", response_model=RespuestaPermiso, status_code=201)
def ruta_crear_permiso(datos_permiso: DatosCrearPermiso, usuario_actual=Depends(pedir_permiso("permissions.create"))):

    return controlador_crear_permiso(datos_permiso)

# ruta para actualizar un permiso
@router.put("/{id_permiso}", response_model=RespuestaPermiso)
def ruta_actualizar_permiso(
    id_permiso: int,
    datos_permiso: DatosActualizarPermiso,
    usuario_actual=Depends(pedir_permiso("permissions.update")),
):
    return controlador_actualizar_permiso(id_permiso, datos_permiso)

# ruta para borrar un permiso
@router.delete("/{id_permiso}", response_model=RespuestaMensaje)
def ruta_borrar_permiso(id_permiso: int, usuario_actual=Depends(pedir_permiso("permissions.delete"))):
    return controlador_borrar_permiso(id_permiso)
