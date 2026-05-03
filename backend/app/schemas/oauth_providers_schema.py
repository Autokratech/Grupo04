from pydantic import BaseModel, field_validator
from typing import List
from datetime import datetime, timezone

# -- Responses
class OAuthProviderResponse(BaseModel):
    access_token: str
    token_type: str
    expires_in: int
    refresh_token: str
    scope: List[str]
    created_at: datetime | None = None
    expires_at: datetime | None = None

    @field_validator("created_at", "expires_at", mode="before")
    @classmethod
    def parse_timestamp(cls, field_value):
        if isinstance(field_value, int):
            return datetime.fromtimestamp(field_value, tz=timezone.utc)
        return field_value
