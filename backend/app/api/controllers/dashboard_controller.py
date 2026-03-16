from fastapi import APIRouter, Request, Depends
from services.dashboard_service import DashboardService
from core.database import create_supabase_client

router = APIRouter(
    prefix="/dashboard",
    tags=["dashboard"],
    responses={404: {"description": "No se ha podido encontrar el recurso solicitado."}},
)


# -- Controladores para gestionar el dashboard
async def get_dashboard(user_id: int, supabase = Depends(create_supabase_client)):
    dashboard_id = DashboardService.get_dashboard(user_id, supabase)
    return dashboard_id 


async def create_dashboard(user_id: int, supabase = Depends(create_supabase_client)):
    return DashboardService.create_dashboard(user_id, supabase)


async def update_dashboard(dashboard_id: int, supabase = Depends(create_supabase_client)):
    return DashboardService.update_dashboard(dashboard_id, supabase)


async def delete_dashboard(dashboard_id: int, supabase = Depends(create_supabase_client)):
    return DashboardService.delete_dashboard(dashboard_id, supabase)


# -- Controladores para gestionar las pestañas del dashboard
async def get_dashboard_tabs(dashboard_id: int, supabase = Depends(create_supabase_client)):
    return DashboardService.get_dashboard_tabs(dashboard_id, supabase)

async def create_dashboard_tab(dashboard_id: int, request: Request, supabase = Depends(create_supabase_client)):
    request_body = await request.json()
    dashboard_tab_name = request_body.get("dashboard_tab_name", "new_tab")
    return DashboardService.create_dashboard_tab(dashboard_id, dashboard_tab_name, supabase)

async def update_dashboard_tab(dashboard_tab_id : int, request: Request, supabase = Depends(create_supabase_client)):
    request_body = await request.json()
    dashboard_tab_column = request_body.get("dashboard_tab_column")
    dashboard_tab_value = request_body.get('dashboard_tab_value')
    return DashboardService.update_dashboard_tab(dashboard_tab_id, dashboard_tab_column, dashboard_tab_value, supabase)

async def delete_dashboard_tab(dashboard_tab_id : int, supabase = Depends(create_supabase_client)):
    return DashboardService.delete_dashboard_tab(dashboard_tab_id, supabase)
