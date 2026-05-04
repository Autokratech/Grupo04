from dataclasses import dataclass
from uuid import UUID


@dataclass
class WidgetModel:
    widget_id: UUID
    widget_type: str
    widget_name: str
    widget_description: str | None
    widget_function: str
