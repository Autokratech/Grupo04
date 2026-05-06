from app.database_sync import supabase

NOMBRE_TABLA_ROLES = "t_roles"

# devuelvo la lista de los roles
def listar_roles():
    respuesta = supabase.table(NOMBRE_TABLA_ROLES).select("*").order("id").execute()
    return respuesta.data or []

# busco un rol por id
def buscar_rol_por_id(id_rol: int):
    respuesta = (
        supabase.table(NOMBRE_TABLA_ROLES)
        .select("*")
        .eq("id", id_rol)
        .limit(1)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# busco rol por nombre
def buscar_rol_por_nombre(nombre_rol: str):
    respuesta = (
        supabase.table(NOMBRE_TABLA_ROLES)
        .select("*")
        .eq("name", nombre_rol)
        .limit(1)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# inserta un nuevo rol
def crear_rol_en_bd(nombre: str, descripcion: str | None = None):
    datos = {"name": nombre, "description": descripcion}
    respuesta = supabase.table(NOMBRE_TABLA_ROLES).insert(datos).execute()

    if not respuesta.data:
        return None

    return respuesta.data[0]

# actualizar un rol por id
def actualizar_rol_en_bd(id_rol: int, campos_a_actualizar: dict):
    respuesta = (
        supabase.table(NOMBRE_TABLA_ROLES)
        .update(campos_a_actualizar)
        .eq("id", id_rol)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# elimino un rol por id
def borrar_rol_en_bd(id_rol: int):
    respuesta = (
        supabase.table(NOMBRE_TABLA_ROLES)
        .delete()
        .eq("id", id_rol)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]
