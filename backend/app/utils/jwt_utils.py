import jwt
from datetime import datetime, timedelta, timezone

from app.config import JWT_ALGORITHM, JWT_SECRET_KEY, JWT_EXPIRE_MINUTES

# Crea el token para que el usuario pueda entrar en rutas privadas
def crear_token_jwt(usuario: dict, nombre_rol: str, lista_permisos: list[str]) -> str:
    fecha_caduca = datetime.now(timezone.utc) + timedelta(minutes=JWT_EXPIRE_MINUTES)

    datos_token = {
        "sub": usuario["id"],
        "email": usuario["email"],
        "role_id": usuario["role_id"],
        "role_name": nombre_rol,
        "permissions": lista_permisos,
        "exp": fecha_caduca,
    }

    return jwt.encode(datos_token, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)

# leo y valido el token.
def leer_token_jwt(token_jwt: str) -> dict:
    return jwt.decode(token_jwt, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
