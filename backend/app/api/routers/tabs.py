from fastapi import APIRouter
from app.api.controllers import tabs_controller as tc
from app.schemas.tab_schema import TabResponse, TabListResponse

router = APIRouter(
    prefix="/api/dashboard",
    tags=["tabs"],
    responses={
        200: {"description" : "La solicitud se ha procesado correctamente."},
        201: {"description" : "La tab se ha creado correctamente."},
        400: {"description" : "El formato de la solicitud es incorrecto."},
        404: {"description": "No se ha podido encontrar el recurso solicitado."},
        500: {"description": "Se ha producido un error interno en el servidor."}
    },
)

# -- Rutas para gestionar las pestañas del dashboard
router.add_api_route("/{dashboard_id}/tabs", tc.get_dashboard_tabs, methods=["GET"], response_model=TabListResponse)
router.add_api_route("/{dashboard_id}/tabs", tc.create_tab, methods=["POST"], response_model=TabResponse)

router.add_api_route("/{dashboard_id}/tabs/{tab_id}", tc.get_tab_by_id, methods=["GET"], response_model=TabResponse)
router.add_api_route("/{dashboard_id}/tabs/{tab_id}", tc.update_tab, methods=["PUT"], response_model=TabResponse)
router.add_api_route("/{dashboard_id}/tabs/{tab_id}", tc.delete_tab, methods=["DELETE"])

# -- BORRAR cuando se tenga el flujo completo, sólo la he puesto para testeo rápido de la funcionalidad:
router.add_api_route("/{dashboard_id}/tabs/max", tc.get_tab_max_index, methods=["GET"]) 
# --
