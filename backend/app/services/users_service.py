from fastapi import HTTPException

from app.core.security import generar_hash_password
from app.repositories import roles_repository, users_repository
from app.schemas.user_schema import DatosActualizarUsuario, DatosCrearUsuario

# listado de usuarios, filtra si se ha feninido el filtro.
def servicio_listar_usuarios(filtro_activo: bool | None = None):
    return users_repository.listar_usuarios(filtro_activo)



# busca un usuario por id y da error si no existe
def servicio_buscar_usuario_por_id(id_usuario: str):

    usuario = users_repository.buscar_usuario_por_id(id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return usuario

#crea un usuario nuevo con su rol y su password
def servicio_crear_usuario(datos_usuario: DatosCrearUsuario):

    usuario_existente = users_repository.buscar_usuario_por_email(datos_usuario.email)
    if usuario_existente:
        raise HTTPException(status_code=400, detail="El email ya esta registrado")

    rol = roles_repository.buscar_rol_por_id(datos_usuario.role_id)
    if not rol:
        raise HTTPException(status_code=404, detail="El rol indicado no existe")

    #hasheamos el password para no guardarlo tal cual.
    hash_password = generar_hash_password(datos_usuario.password)
    usuario_creado = users_repository.crear_usuario_en_bd(
        email=datos_usuario.email,
        password_hash=hash_password,
        role_id=datos_usuario.role_id,
        active=datos_usuario.active,
    )

    if not usuario_creado:
        raise HTTPException(status_code=500, detail="No se pudo crear el usuario")

    return usuario_creado


# Actualiza solo los campos que llegan rellenos
def servicio_actualizar_usuario(id_usuario: str, datos_usuario: DatosActualizarUsuario):

    usuario = users_repository.buscar_usuario_por_id(id_usuario)
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    campos_a_actualizar = datos_usuario.model_dump(exclude_none=True)


    if "email" in campos_a_actualizar:
        otro_usuario = users_repository.buscar_usuario_por_email(campos_a_actualizar["email"])
        if otro_usuario and otro_usuario["id"] != id_usuario:
            raise HTTPException(status_code=400, detail="Ese email ya esta en uso")

    if "role_id" in campos_a_actualizar:
        rol = roles_repository.buscar_rol_por_id(campos_a_actualizar["role_id"])
        if not rol:
            raise HTTPException(status_code=404, detail="El rol indicado no existe")

    if "password" in campos_a_actualizar:
        campos_a_actualizar["password_hash"] = generar_hash_password(campos_a_actualizar["password"])
        del campos_a_actualizar["password"]

    usuario_actualizado = users_repository.actualizar_usuario_en_bd(id_usuario, campos_a_actualizar)
    if not usuario_actualizado:
        raise HTTPException(status_code=500, detail="No se pudo actualizar el usuario")

    return usuario_actualizado

# Borra un usuario por id
def servicio_borrar_usuario(id_usuario: str):

    usuario_borrado = users_repository.borrar_usuario_en_bd(id_usuario)
    if not usuario_borrado:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    return {"mensaje": "Usuario eliminado correctamente"}
