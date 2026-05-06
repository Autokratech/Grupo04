from fastapi import APIRouter
from app.api.controllers import tabs_controller as tc

router = APIRouter(
    prefix="/api/dashboard",
    tags=["tabs"],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)

# -- Rutas para gestionar las pestañas del dashboard
router.add_api_route("/{dashboard_id}/tabs", tc.get_dashboard_tabs, methods=["GET"])
router.add_api_route("/{dashboard_id}/tabs", tc.create_tab, methods=["POST"])

router.add_api_route("/{dashboard_id}/tabs/{tab_id}", tc.get_tab_by_id, methods=["GET"])
router.add_api_route("/{dashboard_id}/tabs/{tab_id}", tc.update_tab, methods=["PUT"])
router.add_api_route("/{dashboard_id}/tabs/{tab_id}", tc.delete_tab, methods=["DELETE"])

# -- BORRAR cuando se tenga el flujo completo, sólo la he puesto para testeo rápido de la funcionalidad:
router.add_api_route("/{dashboard_id}/tabs/max", tc.get_tab_max_index, methods=["GET"]) 
# --