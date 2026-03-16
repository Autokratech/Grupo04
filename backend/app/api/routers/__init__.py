from .oauth import router as oauth_router
from .dashboard import router as dashboard_router

__all__ = ["oauth_router", "dashboard_router"]