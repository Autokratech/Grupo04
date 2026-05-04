from fastapi import HTTPException

from app.repositories import permissions_repository, roles_repository, users_repository
from app.schemas.role_schema import DatosActualizarRol, DatosCrearRol

# TODO: terminar servicio_listar_permisos_de_rol, servicio_quitar_permiso_de_rol


# devuelve la lista de roles
def servicio_listar_roles():

    return roles_repository.listar_roles()

# busca un rol por el
def servicio_buscar_rol_por_id(id_rol: int):
    rol = roles_repository.buscar_rol_por_id(id_rol)
    if not rol:
        raise HTTPException(status_code=404, detail="Rol no encontrado")
    return rol



# crea un nuevo rol
def servicio_crear_rol(datos_rol: DatosCrearRol):
    rol_existente = roles_repository.buscar_rol_por_nombre(datos_rol.name)
    if rol_existente:

        raise HTTPException(status_code=400, detail="Ya existe un rol con ese nombre")

    rol_creado = roles_repository.crear_rol_en_bd(datos_rol.name, datos_rol.description)
    if not rol_creado:
        raise HTTPException(status_code=500, detail="No se pudo crear el rol")

    return rol_creado

# actualiza el rol por el id
def servicio_actualizar_rol(id_rol: int, datos_rol: DatosActualizarRol):
    rol = roles_repository.buscar_rol_por_id(id_rol)
    if not rol:
        raise HTTPException(status_code=404, detail="Rol no encontrado")

    campos_a_actualizar = datos_rol.model_dump(exclude_none=True)
    rol_actualizado = roles_repository.actualizar_rol_en_bd(id_rol, campos_a_actualizar)

    if not rol_actualizado:
        raise HTTPException(status_code=500, detail="No se pudo actualizar el rol")

    return rol_actualizado

# borra un rol, si está asignado devuelve el error.
def servicio_borrar_rol(id_rol: int):

    rol = roles_repository.buscar_rol_por_id(id_rol)
    if not rol:
        raise HTTPException(status_code=404, detail="Rol no encontrado")

    lista_usuarios = users_repository.listar_usuarios()
    hay_usuarios_con_ese_rol = any(usuario["role_id"] == id_rol for usuario in lista_usuarios)
    if hay_usuarios_con_ese_rol:
        raise HTTPException(status_code=400, detail="No puedes borrar un rol que esta en uso por usuarios")

    rol_borrado = roles_repository.borrar_rol_en_bd(id_rol)
    if not rol_borrado:
        raise HTTPException(status_code=500, detail="No se pudo eliminar el rol")

    return {"mensaje": "Rol eliminado correctamente"}

# Devuelve los permisos de un rol
def servicio_listar_permisos_de_rol(id_rol: int):

    rol = roles_repository.buscar_rol_por_id(id_rol)
    if not rol:
        raise HTTPException(status_code=404, detail="Rol no encontrado")

    return permissions_repository.listar_permisos_de_rol(id_rol)



# Devuelve los permisos de un rol
def servicio_asignar_permiso_a_rol(id_rol: int, id_permiso: int):

    rol = roles_repository.buscar_rol_por_id(id_rol)
    if not rol:
        raise HTTPException(status_code=404, detail="Rol no encontrado")

    permiso = permissions_repository.buscar_permiso_por_id(id_permiso)
    if not permiso:
        raise HTTPException(status_code=404, detail="Permiso no encontrado")

    ya_existe = permissions_repository.rol_tiene_permiso(id_rol, id_permiso)
    if ya_existe:
        raise HTTPException(status_code=400, detail="Ese rol ya tiene ese permiso")

    permissions_repository.asignar_permiso_a_rol_en_bd(id_rol, id_permiso)
    return {"mensaje": "Permiso asignado correctamente al rol"}

#quita el permiso de un rol
def servicio_quitar_permiso_de_rol(id_rol: int, id_permiso: int):

    rol = roles_repository.buscar_rol_por_id(id_rol)
    if not rol:
        raise HTTPException(status_code=404, detail="Rol no encontrado")

    permiso = permissions_repository.buscar_permiso_por_id(id_permiso)
    if not permiso:
        raise HTTPException(status_code=404, detail="Permiso no encontrado")

    permissions_repository.quitar_permiso_de_rol_en_bd(id_rol, id_permiso)
    return {"mensaje": "Permiso quitado correctamente del rol"}
