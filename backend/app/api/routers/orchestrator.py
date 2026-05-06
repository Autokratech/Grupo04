from fastapi import APIRouter
from app.api.controllers import orchestrator_controller as oc
from fastapi.sse import EventSourceResponse

router = APIRouter(
    prefix="/api/dashboard",
    tags=["orchestrator"],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)

# -- Rutas para gestionar el orquestador 
router.add_api_route("/{dashboard_id}/tabs/{tab_id}/widgets", oc.get_active_tab_widgets, methods=["GET"], response_class=EventSourceResponse)
