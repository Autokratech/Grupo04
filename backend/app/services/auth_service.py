from fastapi import HTTPException
from app.core.config import SYSTEM_USER_ID
from app.core.config import DEFAULT_ROLE_NAME_FOR_REGISTER
from app.core.security import comprobar_password, crear_token_jwt, generar_hash_password
from app.repositories import permissions_repository, roles_repository, users_repository
from app.schemas.auth_schema import DatosLogin, DatosRegistro
from app.services.audit_service import registrar_evento_auditoria

# Registra un usuario nuevo y devuelve el token
def servicio_registrar_usuario(datos_registro: DatosRegistro):

    usuario_existente = users_repository.buscar_usuario_por_email(datos_registro.email)
    if usuario_existente:
        registrar_evento_auditoria(
            user_id=usuario_existente["id"],
            action="auth.register.error",
            description="Se intenta registro con un email que ya existe",
            meta={
                "status": "error",
                "reason": "email_duplicado",
                "email_intentado": datos_registro.email,
            },
        )
        raise HTTPException(status_code = 400, detail="El email ya esta registrado")

    rol_defecto = roles_repository.buscar_rol_por_nombre(DEFAULT_ROLE_NAME_FOR_REGISTER)
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

    registrar_evento_auditoria(
        user_id=usuario_creado["id"],
        action="auth.register",
        description="Registro de usuario completado correctamente",
        meta={
            "status": "success",
            "email": usuario_creado["email"],
            "role_id": usuario_creado["role_id"],
            "active": usuario_creado["active"],
        },
    )

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
        registrar_evento_auditoria(
             # UUID del sistema
            user_id= SYSTEM_USER_ID,
            action="auth.login.error",
            description="login con usuario inexistente",
            meta={
                "status": "error",
                "reason": "usuario_no_encontrado",
                "email": datos_login.email,
            }
        )
        print ("Pasa por aqui")
    
        raise HTTPException(status_code=401,detail="Email o contraseña incorrectas")

    if usuario.get("active") is not True:
        raise HTTPException(status_code=403, detail="Tu usuario esta desactivado")

    password_ok = comprobar_password(datos_login.password, usuario.get("password_hash", ""))
    if not password_ok:
        registrar_evento_auditoria(
            user_id=usuario["id"],
            action="auth.login.error",
            description="login con contrasena incorrecta",
            meta={
                "status": "error",
                "reason": "password_incorrecta",
                "email": usuario["email"],
            },
        )
        raise HTTPException(status_code=401, detail="Email o contrasena incorrectas")

    rol_usuario = roles_repository.buscar_rol_por_id(usuario["role_id"])
    if not rol_usuario:
        raise HTTPException(status_code=500, detail="El usuario no tiene un rol valido")

    permisos_rol = permissions_repository.listar_permisos_de_rol(usuario["role_id"])
    codigos_permisos = [permiso["code"] for permiso in permisos_rol]
    token_acceso = crear_token_jwt(usuario, rol_usuario["name"], codigos_permisos)

    registrar_evento_auditoria(
        user_id=usuario["id"],
        action="auth.login",
        description="Inicio de sesion correcto",
        meta={
            "status": "success",
            "email": usuario["email"],
            "role_id": usuario["role_id"],
        },
    )

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
