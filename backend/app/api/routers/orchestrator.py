from fastapi import APIRouter, Depends
from app.api.controllers import orchestrator_controller as oc
from fastapi.sse import EventSourceResponse

#Modificar el prefijo y la ruta, de momento lo pongo así para pruebas
router = APIRouter(
    prefix="/orchestrator",
    tags=["orchestrator"],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)

# -- Rutas para gestionar el orquestador 
router.add_api_route("/", oc.get_active_tab_widgets, methods=["GET"], response_class=EventSourceResponse)
