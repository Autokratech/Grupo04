from app.database_sync import supabase

NOMBRE_TABLA_PERMISOS = "t_permissions"
NOMBRE_TABLA_ROL_PERMISO = "t_role_permissions"

# Retorno la lista de permisos
def listar_permisos():

    respuesta = supabase.table(NOMBRE_TABLA_PERMISOS).select("*").order("id").execute()
    return respuesta.data or []

# busco los persmisos por el id
def buscar_permiso_por_id(id_permiso: int):

    respuesta = (
        supabase.table(NOMBRE_TABLA_PERMISOS)
        .select("*")
        .eq("id", id_permiso)
        .limit(1)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# busco los permisos por el codigo
def buscar_permiso_por_codigo(codigo_permiso: str):
    respuesta = (
        supabase.table(NOMBRE_TABLA_PERMISOS)
        .select("*")
        .eq("code", codigo_permiso)
        .limit(1)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# inserta los permisos nuevos
def crear_permiso_en_bd(codigo: str, nombre: str, descripcion: str | None = None):
    datos = {"code": codigo, "name": nombre, "description": descripcion}
    respuesta = supabase.table(NOMBRE_TABLA_PERMISOS).insert(datos).execute()

    if not respuesta.data:
        return None

    return respuesta.data[0]

# Actualizo los permisos por id
def actualizar_permiso_en_bd(id_permiso: int, campos_a_actualizar: dict):

    respuesta = (
        supabase.table(NOMBRE_TABLA_PERMISOS)
        .update(campos_a_actualizar)
        .eq("id", id_permiso)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# borro un persmiso por id
def borrar_permiso_en_bd(id_permiso: int):

    respuesta = (
       supabase.table(NOMBRE_TABLA_PERMISOS)
        .delete()
        .eq("id", id_permiso)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# listo los permisos por rol
def listar_permisos_de_rol(id_rol: int):
    respuesta_rol_permiso = (
        supabase.table(NOMBRE_TABLA_ROL_PERMISO)
        .select("permission_id")
        .eq("role_id", id_rol)
        .execute()
    )

    filas = respuesta_rol_permiso.data or []
    ids_permisos = [fila["permission_id"] for fila in filas]
  
    if not ids_permisos:
        return []

    respuesta = (
        supabase.table(NOMBRE_TABLA_PERMISOS)
        .select("*")
        .in_("id", ids_permisos)
        .order("id")
        .execute()
    )

    return respuesta.data or []

# retorno si un permiso tiene un rol en concreto
def rol_tiene_permiso(id_rol: int, id_permiso: int):
    respuesta = (
        supabase.table(NOMBRE_TABLA_ROL_PERMISO)
        .select("*")
        .eq("role_id", id_rol)
        .eq("permission_id", id_permiso)
        .limit(1)
        .execute()
    )

    return bool(respuesta.data)

# se asigna un permiso a un rol
def asignar_permiso_a_rol_en_bd(id_rol: int, id_permiso: int):
    datos = {"role_id": id_rol, "permission_id": id_permiso}
    respuesta = supabase.table(NOMBRE_TABLA_ROL_PERMISO).insert(datos).execute()
    return respuesta.data or []

# quito la asignasignación de permiso a un rol
def quitar_permiso_de_rol_en_bd(id_rol: int, id_permiso: int):
    respuesta = (
        supabase.table(NOMBRE_TABLA_ROL_PERMISO)
        .delete()
        .eq("role_id", id_rol)
        .eq("permission_id", id_permiso)
        .execute()
    )
    return respuesta.data or []
