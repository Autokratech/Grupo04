from fastapi import APIRouter, Depends
from app.api.controllers import oauth_controller as oc
from app.core.guardias import pedir_usuario_logueado

router = APIRouter(
    prefix="/api/oauth",
    tags=["OAuth"],
    dependencies=[Depends(pedir_usuario_logueado)],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)

# -- Rutas para gestionar las conexiones OAuth
router.add_api_route("/{provider}", oc.oauth_login, methods=["GET"])
router.add_api_route("/{provider}/callback", oc.oauth_callback, methods=["GET"])
