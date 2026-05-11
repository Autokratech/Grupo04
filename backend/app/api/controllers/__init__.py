from .dashboard_controller import (
    get_user_dashboard, create_dashboard, update_dashboard, delete_dashboard
)

from .oauth_controller import oauth_login, oauth_callback

from .tabs_controller import (
    get_dashboard_tabs, get_tab_by_id, get_tab_max_index, 
    create_tab, update_tab, delete_tab
)

from .widgets_controller import (
    get_widget, get_all_available_widgets, search_widgets,
    create_widget, update_widget, delete_widget
)

from .orchestrator_controller import get_active_tab_widgets

from .auth_controller import controlador_login_usuario, controlador_registrar_usuario

from .metrics_controller import (
    controlador_metricas_por_resource_type, controlador_recursos_por_resource_type, 
    controlador_reportar_metrica, controlador_ultima_metrica
)

from .permissions_controller import (
    controlador_listar_permisos, controlador_buscar_permiso_por_id, controlador_crear_permiso,
    controlador_actualizar_permiso, controlador_borrar_permiso
)

from .roles_controller import (
    controlador_listar_roles, controlador_buscar_rol_por_id, controlador_crear_rol,
    controlador_actualizar_rol, controlador_borrar_rol, controlador_listar_permisos_de_rol,
    controlador_asignar_permiso_a_rol, controlador_quitar_permiso_de_rol
)

from .users_controller import (
    controlador_listar_usuarios, controlador_buscar_usuario_por_id, controlador_crear_usuario,
    controlador_actualizar_usuario, controlador_borrar_usuario
)
