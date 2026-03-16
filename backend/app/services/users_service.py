from fastapi import HTTPException
from app.core.security import hash_password
from app.repositories import users_repository
from app.schemas.user_schema import UserCreate

# Lógica de negocio para usuarios, aqui van todos los métodos relacionados con la gestión de usuarios,
# como validaciones, reglas de negocio, etc.
def list_users():
    users = users_repository.get_all_users()

    return [
        {
            "id": user.id,
            "nombre": user.nombre,
            "email": user.email
        }
        for user in users
    ]


def get_user(user_id: int):
    user = users_repository.get_user_by_id(user_id)

    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return {
        "id": user.id,
        "nombre": user.nombre,
        "email": user.email
    }


def create_user(data: UserCreate):
    existing_user = users_repository.get_user_by_email(data.email)

    if existing_user:
        raise HTTPException(status_code=400, detail="El email ya está registrado")

    new_user = users_repository.create_user(
        nombre=data.nombre,
        email=data.email,
        password_hash=hash_password(data.password)
    )

    return {
        "id": new_user.id,
        "nombre": new_user.nombre,
        "email": new_user.email
    }
