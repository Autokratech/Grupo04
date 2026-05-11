from pydantic import BaseModel, model_validator
from app.core.exceptions import BadRequestError
from uuid import UUID

# -- Requests
class DashboardCreate(BaseModel):
    dashboard_theme : str | None = "default"
    dashboard_language : str | None = "spanish"

class DashboardUpdate(BaseModel):
    dashboard_theme : str | None = None
    dashboard_language : str | None = None

    @model_validator(mode="after")
    def verify_request_data(self):
        if not self.dashboard_theme and not self.dashboard_language:
            raise BadRequestError("No se ha proporcionado ningún parámetro para actualizar los datos.")
        return self

# -- Responses
class DashboardResponse(BaseModel):
    dashboard_id: UUID
    dashboard_theme: str 
    dashboard_language: str 

