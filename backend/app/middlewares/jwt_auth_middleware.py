from starlette.middleware.base import BaseHTTPMiddleware

from app.utils.jwt_utils import leer_token_jwt
from app.repositories import permissions_repository, roles_repository, users_repository

# Mira si viene un Bearer token y carga el usuario en la request
class MiddlewareJwt(BaseHTTPMiddleware):


    async def dispatch(self, request, call_next):
        request.state.usuario_actual = None
        request.state.rol_actual = None
        request.state.permisos_actuales = []

        ruta = request.url.path
        rutas_publicas_exactas = {"/", "/openapi.json"}
        prefijos_publicos = ["/docs", "/redoc", "/api/auth/"]

        es_ruta_publica = ruta in rutas_publicas_exactas or any(
            ruta.startswith(prefijo) for prefijo in prefijos_publicos
        )

        cabecera_autorizacion = request.headers.get("Authorization", "")

        if cabecera_autorizacion.startswith("Bearer "):
            token_jwt = cabecera_autorizacion.replace("Bearer ", "", 1).strip()

            try:
                datos_token = leer_token_jwt(token_jwt)
                id_usuario = datos_token.get("sub")
                usuario = users_repository.buscar_usuario_por_id(id_usuario)

                if usuario and usuario.get("active") is True:
                    rol = roles_repository.buscar_rol_por_id(usuario["role_id"])
                    permisos_rol = permissions_repository.listar_permisos_de_rol(usuario["role_id"])
                    codigos_permisos = [permiso["code"] for permiso in permisos_rol]

                    request.state.usuario_actual = usuario
                    request.state.rol_actual = rol
                    request.state.permisos_actuales = codigos_permisos
            except Exception:
                request.state.usuario_actual = None
                request.state.rol_actual = None
                request.state.permisos_actuales = []

        respuesta = await call_next(request)
        return respuesta
