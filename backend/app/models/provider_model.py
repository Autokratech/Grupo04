from pydantic import BaseModel


class Provider(BaseModel):
    provider_name : str
    provider_type : str


class ProviderType(BaseModel):
    provider_type : str