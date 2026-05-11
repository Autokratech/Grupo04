from fastapi import APIRouter
from fastapi.sse import EventSourceResponse
from app.api.controllers import orchestrator_controller as oc
from app.schemas.orchestrator_schema import AddTabWidgetResponse

router = APIRouter(
    prefix="/api/dashboard",
    tags=["Orchestrator"],
    responses={
        200: {"description" : "La solicitud se ha procesado correctamente."},
        201: {"description" : "El recurso se ha creado correctamente."},
        400: {"description" : "El formato de la solicitud es incorrecto."},
        404: {"description": "No se ha podido encontrar el recurso solicitado."},
        500: {"description": "Se ha producido un error interno en el servidor."}
    },
)

# -- Rutas para gestionar el orquestador 
router.add_api_route("/{dashboard_id}/tabs/{tab_id}/widgets", oc.get_active_tab_widgets, methods=["GET"], response_class=EventSourceResponse)
router.add_api_route("/{dashboard_id}/tabs/{tab_id}/widgets", oc.add_widget_to_active_tab, methods=["POST"], response_model=AddTabWidgetResponse)
