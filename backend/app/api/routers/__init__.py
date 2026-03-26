from .oauth import router as oauth_router
from .dashboard import router as dashboard_router
from .widgets import router as widgets_router
from .tabs import router as tabs_router
from .orchestrator import router as orchestrator_router

__all__ = ["oauth_router", "dashboard_router", "widgets_router", "tabs_router", "orchestrator_router"]