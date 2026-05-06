from fastapi import APIRouter
from app.api.controllers import dashboard_controller as dc

router = APIRouter(
    prefix="/api/dashboard",
    tags=["dashboard"],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)

# -- Rutas para gestionar el dashboard 
router.add_api_route("/", dc.get_user_dashboard, methods=["GET"])
router.add_api_route("/", dc.create_dashboard, methods=["POST"])
router.add_api_route("/{dashboard_id}", dc.update_dashboard, methods=["PUT"])
router.add_api_route("/{dashboard_id}", dc.delete_dashboard, methods=["DELETE"])
