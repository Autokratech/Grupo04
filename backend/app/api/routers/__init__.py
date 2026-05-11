from .oauth import router as oauth_router
from .dashboard import router as dashboard_router
from .widgets import router as widgets_router
from .tabs import router as tabs_router
from .orchestrator import router as orchestrator_router
from .users import router as users_router
from .permissions import router as permissions_router
from .roles import router as roles_router
from .auth import router as auth_router
from .metrics import router as metrics_router

__all__ = ["oauth_router", "dashboard_router", "widgets_router", "tabs_router", "orchestrator_router", 
           "users_router", "permissions_router", "roles_router", "auth_router", "metrics_router"]