from fastapi import APIRouter
from app.api.controllers import oauth_controller as oc

router = APIRouter(
    prefix="/oauth",
    tags=["oauth"],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)

# -- Rutas para gestionar las conexiones OAuth
router.add_api_route("/{provider}", oc.oauth_login, methods=["GET"])
router.add_api_route("/{provider}/callback", oc.oauth_callback, methods=["GET"])
