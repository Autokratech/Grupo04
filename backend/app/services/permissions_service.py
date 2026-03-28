from fastapi import HTTPException

from app.repositories import permissions_repository
from app.schemas.permission_schema import DatosActualizarPermiso, DatosCrearPermiso

# devuelve la lista de permisos
def servicio_listar_permisos():
    return permissions_repository.listar_permisos()

# busca un permiso por id
def servicio_buscar_permiso_por_id(id_permiso: int):
    permiso = permissions_repository.buscar_permiso_por_id(id_permiso)
    if not permiso:
        raise HTTPException(status_code=404, detail="Permiso no encontrado.")
    return permiso

# crea un permiso
def servicio_crear_permiso(datos_permiso: DatosCrearPermiso):
    permiso_existente = permissions_repository.buscar_permiso_por_codigo(datos_permiso.code)
    if permiso_existente:
        raise HTTPException(status_code=400, detail="Ya existe un permiso con ese codigo")

    permiso_creado = permissions_repository.crear_permiso_en_bd(
        datos_permiso.code,
        datos_permiso.name,
        datos_permiso.description,
    )

    if not permiso_creado:
        raise HTTPException(status_code=500, detail="No se pudo crear el permiso")

    return permiso_creado

#actualizao el permiso por el id
def servicio_actualizar_permiso(id_permiso: int, datos_permiso: DatosActualizarPermiso):

    permiso = permissions_repository.buscar_permiso_por_id(id_permiso)
    if not permiso:
        raise HTTPException(status_code=404,detail="Permiso no encontrado")

    campos_a_actualizar = datos_permiso.model_dump(exclude_none=True)
    permiso_actualizado = permissions_repository.actualizar_permiso_en_bd(id_permiso, campos_a_actualizar)

    if not permiso_actualizado:
        raise HTTPException(status_code=500, detail="No se pudo actualizar el permiso")

    return permiso_actualizado

# borra el permiso por el id.
def servicio_borrar_permiso(id_permiso: int):
    permiso = permissions_repository.buscar_permiso_por_id(id_permiso)
    if not permiso:
        raise HTTPException(status_code=404, detail="Permiso no encontrado")

    permiso_borrado = permissions_repository.borrar_permiso_en_bd(id_permiso)
    if not permiso_borrado:
        raise HTTPException(status_code=500, detail="No se pudo eliminar el permiso")

    return {"mensaje": "Permiso eliminado correctament."}
