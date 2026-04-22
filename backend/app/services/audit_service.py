from app.repositories import audit_repository


# Servicio centralizado de auditoria.
# Si falla el insert del log, nunca rompe la operacion principal.
def registrar_evento_auditoria(
    user_id: str | None,
    action: str,
    description: str | None = None,
    meta: dict | None = None,
):
    # if not user_id:
    #     return None

    try:
        return audit_repository.crear_registro_auditoria_en_bd(
            user_id=user_id,
            action=action,
            description=description,
            meta=meta or {},
        )
    except Exception:
        return None
