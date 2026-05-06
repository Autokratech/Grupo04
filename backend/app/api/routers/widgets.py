from fastapi import APIRouter
from app.api.controllers import widgets_controller as wc

router = APIRouter(
    prefix="/api/widgets",
    tags=["widgets"],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)


# -- Rutas para gestionar los widgets 
router.add_api_route("/", wc.get_all_available_widgets, methods=["GET"])  #Esta podría ser la ruta del catálogo
router.add_api_route("/search", wc.search_widgets, methods=["GET"])
router.add_api_route("/{widget_id}", wc.get_widget, methods=["GET"])
router.add_api_route("/", wc.create_widget, methods=["POST"])
router.add_api_route("/{widget_id}", wc.update_widget, methods=["PUT"])
router.add_api_route("/{widget_id}", wc.delete_widget, methods=["DELETE"])
