from fastapi import HTTPException

from app.core.config import DEFAULT_ROLE_NAME_FOR_REGISTER
from app.core.security import comprobar_password, crear_token_jwt, generar_hash_password
from app.repositories import permissions_repository, roles_repository, users_repository
from app.schemas.auth_schema import DatosLogin, DatosRegistro

# Registra un usuario nuevo y devuelve el token
def servicio_registrar_usuario(datos_registro: DatosRegistro):

    usuario_existente = users_repository.buscar_usuario_por_email(datos_registro.email)
    if usuario_existente:
        raise HTTPException(status_code = 400, detail="El email ya esta registrado")

    rol_defecto = roles_repository.buscar_rol_por_nombre(ROL_POR_DEFECTO_REGISTRO)
    if not rol_defecto:
        raise HTTPException(status_code=500, detail="no existe el rol por defecto para el registro")

    hash_password = generar_hash_password(datos_registro.password)
    usuario_creado = users_repository.crear_usuario_en_bd(
        email=datos_registro.email,
        password_hash=hash_password,
        role_id=rol_defecto["id"],
        active=True,
    )

    if not usuario_creado:
        raise HTTPException(status_code=500,detail="No se pudo registrar el usuario")

    permisos_rol = permissions_repository.listar_permisos_de_rol(usuario_creado["role_id"])
    codigos_permisos = [permiso["code"] for permiso in permisos_rol]
    token_acceso = crear_token_jwt(usuario_creado, rol_defecto["name"], codigos_permisos)

    return {
        "access_token": token_acceso,
        "token_type": "bearer",
        "user": {
            "id": usuario_creado["id"],
            "email": usuario_creado["email"],
            "role_id": usuario_creado["role_id"],
            "active": usuario_creado["active"],
            "created_at": usuario_creado["created_at"],
        },
    }

# compruebb el email y password, y si todo va bien devuelve token
def servicio_login_usuario(datos_login: DatosLogin):

    usuario = users_repository.buscar_usuario_por_email(datos_login.email)
    if not usuario:
        raise HTTPException(status_code=401,detail="Email o contrasena incorrectas")

    if usuario.get("active") is not True:
        raise HTTPException(status_code=403, detail="Tu usuario esta desactivado")

    password_ok = comprobar_password(datos_login.password, usuario.get("password_hash", ""))
    if not password_ok:
        raise HTTPException(status_code=401, detail="Email o contrasena incorrectas")

    rol_usuario = roles_repository.buscar_rol_por_id(usuario["role_id"])
    if not rol_usuario:
        raise HTTPException(status_code=500, detail="El usuario no tiene un rol valido")

    permisos_rol = permissions_repository.listar_permisos_de_rol(usuario["role_id"])
    codigos_permisos = [permiso["code"] for permiso in permisos_rol]
    token_acceso = crear_token_jwt(usuario, rol_usuario["name"], codigos_permisos)



    return {
        "access_token": token_acceso,
        "token_type": "bearer",
        "user": {
            "id": usuario["id"],
            "email": usuario["email"],
            "role_id": usuario["role_id"],
            "active": usuario["active"],
            "created_at": usuario["created_at"],
        },
    }
