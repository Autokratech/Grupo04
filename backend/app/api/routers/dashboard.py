from fastapi import APIRouter
from app.api.controllers import dashboard_controller as dc
from app.schemas.dashboard_schema import DashboardResponse

router = APIRouter(
    prefix="/api/dashboard",
    tags=["dashboard"],
    responses={
        200: {"description" : "La solicitud se ha procesado correctamente."},
        201: {"description" : "El dashboard se ha creado correctamente."},
        400: {"description" : "El formato de la solicitud es incorrecto."},
        404: {"description": "No se ha podido encontrar el dashboard solicitado."},
        500: {"description": "Se ha producido un error interno en el servidor."}
    },
)

# -- Rutas para gestionar el dashboard 
router.add_api_route("/", dc.get_user_dashboard, methods=["GET"], response_model=DashboardResponse)
router.add_api_route("/", dc.create_dashboard, methods=["POST"], response_model=DashboardResponse)
router.add_api_route("/{dashboard_id}", dc.update_dashboard, methods=["PUT"], response_model=DashboardResponse)
router.add_api_route("/{dashboard_id}", dc.delete_dashboard, methods=["DELETE"])
