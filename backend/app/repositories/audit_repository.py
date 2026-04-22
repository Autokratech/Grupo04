from datetime import datetime, timezone
import uuid

from app.core.database import supabase

NOMBRE_TABLA_AUDITORIA = "t_audit_log"


# Inserta un registro de auditoria adaptado a la tabla real del proyecto.
def crear_registro_auditoria_en_bd(
    user_id: str,
    action: str,
    description: str | None = None,
    meta: dict | None = None,
):
    datos = {
        "id": str(uuid.uuid4()),
        "user_id": user_id,
        "action": action,
        "description": description,
        "meta": meta or {},
        "created_at": datetime.now(timezone.utc).isoformat(),
    }

    respuesta = supabase.table(NOMBRE_TABLA_AUDITORIA).insert(datos).execute()

    if not respuesta.data:
        return None

    return respuesta.data[0]
