from app.database_sync import supabase

NOMBRE_TABLA_USUARIOS = "t_users"

# devuelve la lista de usuario, si se le especifica un filtro lo aplica.
def listar_usuarios(filtro_activo: bool | None = None):
    consulta = supabase.table(NOMBRE_TABLA_USUARIOS).select("*").order("created_at", desc=True)

    if filtro_activo is not None:
        consulta = consulta.eq("active", filtro_activo)

    respuesta = consulta.execute()
    return respuesta.data or []

# busca un usuario por id
def buscar_usuario_por_id(id_usuario: str):
    respuesta = (
        supabase.table(NOMBRE_TABLA_USUARIOS)
        .select("*")
        .eq("id", id_usuario)
        .limit(1)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# busca un usuario por el email
def buscar_usuario_por_email(email: str):
    respuesta = (
        supabase.table(NOMBRE_TABLA_USUARIOS)
        .select("*")
        .eq("email", email)
        .limit(1)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# nuevo usuario
def crear_usuario_en_bd(email: str, password_hash: str, role_id: int, active: bool = True):
    datos = {
        "email": email,
        "password_hash": password_hash,
        "role_id": role_id,
        "active": active,
    }

    respuesta = supabase.table(NOMBRE_TABLA_USUARIOS).insert(datos).execute()

    if not respuesta.data:
        return None

    return respuesta.data[0]

# actualizar usuario por el id
def actualizar_usuario_en_bd(id_usuario: str, campos_a_actualizar: dict):
    respuesta = (
        supabase.table(NOMBRE_TABLA_USUARIOS)
        .update(campos_a_actualizar)
        .eq("id", id_usuario)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]

# borra el usuario por el id
def borrar_usuario_en_bd(id_usuario: str):
    respuesta = (
        supabase.table(NOMBRE_TABLA_USUARIOS)
        .delete()
        .eq("id", id_usuario)
        .execute()
    )

    if not respuesta.data:
        return None

    return respuesta.data[0]
