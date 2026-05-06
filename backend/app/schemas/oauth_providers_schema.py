from pydantic import BaseModel, field_validator, model_validator
from typing import List
from datetime import datetime, timezone, timedelta

# -- Responses

#Nota: los parámetros refresh_token y aquellos otros relativos al TTL del token son opcionales porque algunos tokens son permanentes
class OAuthProviderResponse(BaseModel):
    access_token: str
    token_type: str
    expires_in: int | None = None  
    refresh_token: str | None = None
    scope: List[str]
    created_at: datetime | None = None
    expires_at: datetime | None = None

    @field_validator("created_at", "expires_at", mode="before")
    @classmethod
    def parse_timestamp(cls, field_value):
        if isinstance(field_value, int) and field_value is not None:
            return datetime.fromtimestamp(field_value, tz=timezone.utc)
        return field_value
    
    @model_validator(mode="after")
    def set_expiration_data(self):
        if self.created_at is None:
            self.created_at = datetime.now(timezone.utc)

        if self.expires_in is not None and self.expires_at is None:
            self.expires_at = self.created_at + timedelta(seconds=self.expires_in)

        return self

