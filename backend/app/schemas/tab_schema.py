from pydantic import BaseModel, field_validator, model_validator
from app.core.exceptions import BadRequestError, InvalidValueError
from typing import List
from uuid import UUID


#-- Requests
class TabCreate(BaseModel):
    tab_name : str | None = "new_tab"
    tab_index : int | None = None

    @field_validator('tab_index', mode='before')
    @classmethod
    def verify_index_number(cls, index : int):
        if index <= 0:
            raise InvalidValueError("El valor del índice de la pestaña no puede ser inferior a 1.")
        return index

class TabUpdate(BaseModel):
    tab_name : str | None = None
    tab_index : int | None = None

    @model_validator(mode="after")
    def verify_request_data(self):
        if not self.tab_name and not self.tab_index:
            raise BadRequestError("No se ha proporcionado ningún parámetro para actualizar los datos.")
        return self

    @field_validator('tab_index', mode='before')
    @classmethod
    def verify_index_number(cls, index : int):
        if index <= 0:
            raise InvalidValueError("El valor del índice de la pestaña no puede ser inferior a 1.")
        return index


#-- Responses
class TabResponse(BaseModel):
    tab_id : UUID
    tab_index : int
    tab_name : str


class TabListResponse(BaseModel):
    tabs : List[TabResponse]
