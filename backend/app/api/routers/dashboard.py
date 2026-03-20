from fastapi import APIRouter
from api.controllers import dashboard_controller as dc

router = APIRouter(
    prefix="/dashboard",
    tags=["dashboard"],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)

# -- Rutas para gestionar el dashboard 
router.add_api_route("/users/{user_id}", dc.get_dashboard, methods=["GET"])
router.add_api_route("/users/{user_id}", dc.create_dashboard, methods=["POST"])
router.add_api_route("/{dashboard_id}", dc.update_dashboard, methods=["PUT"])
router.add_api_route("/{dashboard_id}", dc.delete_dashboard, methods=["DELETE"])

# -- Rutas para gestionar las pestañas del dashboard
router.add_api_route("/{dashboard_id}/tabs", dc.get_dashboard_tabs, methods=["GET"])
router.add_api_route("/{dashboard_id}/tabs", dc.create_dashboard_tab, methods=["POST"])
router.add_api_route("/{dashboard_id}/tabs/{dashboard_tab_id}", dc.update_dashboard_tab, methods=["PUT"])
router.add_api_route("/{dashboard_id}/tabs/{dashboard_tab_id}", dc.delete_dashboard_tab, methods=["DELETE"])

# -- Rutas para gestionar los widgets del dashboard
router.add_api_route("/tabs/{dashboard_tab_id}/widgets", dc.get_all_tab_widgets, methods=["GET"])
router.add_api_route("/tabs/{dashboard_tab_id}/widgets", dc.add_tab_widget, methods=["POST"])
router.add_api_route("/tabs/{dashboard_tab_id}/widgets/{widget_id}", dc.update_tab_widget, methods=["PUT"])
router.add_api_route("/tabs/{dashboard_tab_id}/widgets/{widget_id}", dc.delete_tab_widget, methods=["DELETE"])
