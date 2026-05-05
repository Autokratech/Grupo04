from pydantic import BaseModel


class WidgetModel(BaseModel):
    widget_type: str | None = None
    widget_name : str | None = None
    widget_description: str | None = None
    widget_function: str | None = None
