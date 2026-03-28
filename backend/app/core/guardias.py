from fastapi import Depends, HTTPException, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

esquema_bearer = HTTPBearer()

# Comprueba que hay un usuario cargado en la request
def pedir_usuario_logueado(
    request: Request,
    credenciales: HTTPAuthorizationCredentials = Depends(esquema_bearer),
):

    usuario_actual = getattr(request.state, "usuario_actual", None)

    if not usuario_actual:
        raise HTTPException(status_code=401, detail="Necesitas iniciar sesion")

    return usuario_actual

# Deja pasar solo a quien tenga un rol concreto.
def pedir_rol(nombre_rol_necesario: str):

    def validar_rol(request: Request, usuario_actual=Depends(pedir_usuario_logueado)):
        rol_actual = getattr(request.state, "rol_actual", None)

        if not rol_actual:
            raise HTTPException(status_code=403, detail="Tu usuario no tiene rol asignado")

        if rol_actual["name"] != nombre_rol_necesario and rol_actual["name"] != "superadmin":
            raise HTTPException(status_code=403, detail="No tienes el rol necesario")

        return usuario_actual

    return validar_rol

# Deja pasar solo si el usuario tiene el permiso pedido.
def pedir_permiso(codigo_permiso_necesario: str):


    def validar_permiso(request: Request, usuario_actual=Depends(pedir_usuario_logueado)):
        rol_actual = getattr(request.state, "rol_actual", None)
        permisos_actuales = getattr(request.state, "permisos_actuales", [])

        if rol_actual and rol_actual["name"] == "SUPERADMIN":
            return usuario_actual

        if codigo_permiso_necesario not in permisos_actuales:
            raise HTTPException(status_code=403, detail="No tienes permiso para esta accion")

        return usuario_actual

    return validar_permiso
