from fastapi import Request

from app.repositories import audit_repository


# Obtiene IP real si viene por proxy, y si no la IP del cliente.
def obtener_ip_request(request: Request | None):
    if not request:
        return None

    x_forwarded_for = request.headers.get("x-forwarded-for")
    if x_forwarded_for:
        return x_forwarded_for.split(",")[0].strip()

    if request.client:
        return request.client.host

    return None


# Obtiene el user-agent de la request.
def obtener_user_agent_request(request: Request | None):
    if not request:
        return None

    return request.headers.get("user-agent")


# Servicio centralizado de auditoria.

def registrar_evento_auditoria(
    request: Request | None,
    user_id: str | None,
    action: str,
    description: str | None = None,
    meta: dict | None = None,
):
    if not user_id:
        return None

    try:
        meta_final = {
            **(meta or {}),
            "request": {
                "ip_address": obtener_ip_request(request),
                "user_agent": obtener_user_agent_request(request),
            },
        }

        return audit_repository.crear_registro_auditoria_en_bd(
            user_id=user_id,
            action=action,
            description=description,
            meta=meta_final,
        )
    except Exception:
        return None
