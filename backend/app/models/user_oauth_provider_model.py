from pydantic import BaseModel, field_validator
from datetime import datetime
from uuid import UUID

class UserOAuthProvider(BaseModel):
    user_id: UUID 
    provider_name: str
    access_token: str
    refresh_token: str | None = None
    dek: str
    created_at: datetime | None = None
    expires_at: datetime | None = None


    @field_validator("created_at", "expires_at", mode="before")
    @classmethod
    def parse_timestamp(cls, field_value):
        if isinstance(field_value, str) and field_value is not None:
            return datetime.fromisoformat(field_value)
        return field_value
 