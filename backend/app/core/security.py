import hashlib
import hmac
import os
from datetime import datetime, timedelta, timezone

import jwt

from app.core.config import JWT_ALGORITHM, JWT_SECRET_KEY, JWT_EXPIRE_MINUTES

# hasheamos el password para no guardarla en plano.
def generar_hash_password(password_plano: str) -> str:
    sal = os.urandom(16)
    vueltas = 120000
    hash_generado = hashlib.pbkdf2_hmac(
        "sha256",
        password_plano.encode("utf-8"),
        sal,
        vueltas,
    )
    return f"pbkdf2_sha256${vueltas}${sal.hex()}${hash_generado.hex()}"

# Comprueba si la password que mete el usuario es la buena.
def comprobar_password(password_plano: str, hash_guardado: str) -> bool:
    if not hash_guardado or not hash_guardado.startswith("pbkdf2_sha256$"):
        return False

    _, vueltas, sal_hex, hash_bd = hash_guardado.split("$", 3)
    hash_generado = hashlib.pbkdf2_hmac(
        "sha256",
        password_plano.encode("utf-8"),
        bytes.fromhex(sal_hex),
        int(vueltas),
    ).hex()

    return hmac.compare_digest(hash_generado, hash_bd)

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
