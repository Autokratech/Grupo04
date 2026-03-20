from fastapi import Request, Depends
from services.widget_service import WidgetService
from core.database import create_supabase_client


# -- Controladores para gestionar los widgets en general
async def get_widget(widget_id : int, supabase = Depends(create_supabase_client)):
    widget_data = WidgetService.get_widget(widget_id, supabase)
    return widget_data

async def get_all_widgets(request: Request, supabase = Depends(create_supabase_client)):
    widget_filters = dict(request.query_params)
    widgets_list = WidgetService.get_all_widgets(widget_filters, supabase)
    return widgets_list

async def create_widget(request: Request, supabase = Depends(create_supabase_client)):
    widget_data = await request.json()
    response = WidgetService.create_widget(widget_data, supabase)
    return response

async def update_widget(widget_id : int, request: Request, supabase = Depends(create_supabase_client)):
    request_body = await request.json()
    widget_column = request_body.get("widget_column")
    widget_value = request_body.get('widget_value')
    response = WidgetService.update_widget(widget_id, widget_column, widget_value, supabase)
    return response

async def delete_widget(widget_id : int, supabase = Depends(create_supabase_client)):
    response = WidgetService.delete_widget(widget_id, supabase)
    return response
