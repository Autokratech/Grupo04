from pydantic import BaseModel, Json


class Endpoint(BaseModel):
    provider_name : str 
    data_type : str
    endpoint_path : str
    endpoint_description : str | None = None

class EndpointPath(BaseModel):
    endpoint_path : str
