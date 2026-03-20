from fastapi import Request, Depends
from services.dashboard_service import DashboardService
from services.widget_service import WidgetService
from core.database import create_supabase_client

## NOTA: Endpoints temporales para probar cada funcionalidad por separado.

# -- Controladores para gestionar el dashboard
async def get_dashboard(user_id: int, supabase = Depends(create_supabase_client)):  
    return DashboardService.get_dashboard(user_id, supabase)


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


# -- Controladores para gestionar los widgets de una pestaña en concreto
async def get_all_tab_widgets(dashboard_tab_id : int, supabase = Depends(create_supabase_client)):
    widgets_list = WidgetService.get_all_tab_widgets(dashboard_tab_id, supabase)
    return widgets_list

async def add_tab_widget(dashboard_tab_id: int, request: Request, supabase = Depends(create_supabase_client)):
    widget_data = await request.json()
    widget_data["dashboard_tab_id"] = dashboard_tab_id
    response = WidgetService.add_tab_widget(widget_data, supabase)
    return response

async def update_tab_widget(widget_id : int, dashboard_tab_id : int, request: Request, supabase = Depends(create_supabase_client)):
    request_body = await request.json()
    widget_tab_column = request_body.get("widget_tab_column")
    widget_tab_value = request_body.get('widget_tab_value')
    response = WidgetService.update_tab_widget(widget_id, dashboard_tab_id, widget_tab_column, widget_tab_value, supabase)
    return response

async def delete_tab_widget(widget_id : int, dashboard_tab_id : int, supabase = Depends(create_supabase_client)):
    response = WidgetService.delete_tab_widget(widget_id, dashboard_tab_id, supabase)
    return response
