from fastapi import APIRouter, Depends, Query, Request

from app.controllers.users_controller import (
    controlador_actualizar_usuario,
    controlador_borrar_usuario,
    controlador_buscar_usuario_por_id,
    controlador_crear_usuario,
    controlador_listar_usuarios,
)
from app.schemas.user_schema import DatosActualizarUsuario, DatosCrearUsuario, RespuestaMensaje, RespuestaUsuario
from app.core.guardias import pedir_permiso, pedir_usuario_logueado

router = APIRouter(prefix="/users", tags=["Users"])

# ruta que devuelve el usuario logado y el token
@router.get("/me")
def ruta_mi_usuario(request: Request, usuario_actual=Depends(pedir_usuario_logueado)):
    return request.state.usuario_actual

# ruta para listar los usuarios, con opcion de filtrar por los activos.
@router.get("/", response_model=list[RespuestaUsuario])
def ruta_listar_usuarios(
    filtro_activo: bool | None = Query(default=None),
    usuario_actual=Depends(pedir_permiso("users.read")),
):
    return controlador_listar_usuarios(filtro_activo)

# ruta para buscar buscar un usuario por el id
@router.get("/{id_usuario}", response_model=RespuestaUsuario)
def ruta_buscar_usuario_por_id(id_usuario: str, usuario_actual=Depends(pedir_permiso("users.read"))):
    return controlador_buscar_usuario_por_id(id_usuario)


# ruta para crear un usuario nuevo
@router.post("/", response_model=RespuestaUsuario, status_code=201)
def ruta_crear_usuario(datos_usuario: DatosCrearUsuario, usuario_actual=Depends(pedir_permiso("users.create"))):
    return controlador_crear_usuario(datos_usuario)

# ruta para actualizar un usuario
@router.put("/{id_usuario}", response_model=RespuestaUsuario)
def ruta_actualizar_usuario(
    id_usuario: str,
    datos_usuario: DatosActualizarUsuario,
    usuario_actual=Depends(pedir_permiso("users.update")),
):
    return controlador_actualizar_usuario(id_usuario, datos_usuario)

# ruta para borrar un usuario
@router.delete("/{id_usuario}", response_model=RespuestaMensaje)
def ruta_borrar_usuario(id_usuario: str, usuario_actual=Depends(pedir_permiso("users.delete"))):
    return controlador_borrar_usuario(id_usuario)
