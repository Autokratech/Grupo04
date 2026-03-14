from fastapi import APIRouter
from api.controllers.oauth_controller import oauth_login, oauth_callback

router = APIRouter(
    prefix="/oauth",
    tags=["oauth"],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)

router.add_api_route("/{provider}", oauth_login, methods=["GET"])
router.add_api_route("/{provider}/callback", oauth_callback, methods=["GET"])
