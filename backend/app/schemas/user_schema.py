from pydantic import BaseModel, EmailStr

# Modelos para la creación y respuesta de usuarios

class UserCreate(BaseModel):
    nombre: str
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    nombre: str
    email: EmailStr
