from app.core.database import supabase
from app.models.user_model import UserModel

TABLE_NAME = "users"


def map_row_to_user(row: dict) -> UserModel:
    return UserModel(
        id=row["id"],
        nombre=row["nombre"],
        email=row["email"],
        password_hash=row["password_hash"]
    )


def get_all_users():
    response = supabase.table(TABLE_NAME).select("id,nombre,email,password_hash").execute()

    if not response.data:
        return []

    return [map_row_to_user(row) for row in response.data]


def get_user_by_id(user_id: int):
    response = (
        supabase
        .table(TABLE_NAME)
        .select("id,nombre,email,password_hash")
        .eq("id", user_id)
        .limit(1)
        .execute()
    )

    if not response.data:
        return None

    return map_row_to_user(response.data[0])


def get_user_by_email(email: str):
    response = (
        supabase
        .table(TABLE_NAME)
        .select("id,nombre,email,password_hash")
        .eq("email", email)
        .limit(1)
        .execute()
    )

    if not response.data:
        return None

    return map_row_to_user(response.data[0])


def create_user(nombre: str, email: str, password_hash: str):
    payload = {
        "nombre": nombre,
        "email": email,
        "password_hash": password_hash
    }

    response = supabase.table(TABLE_NAME).insert(payload).execute()

    if not response.data:
        return None

    return map_row_to_user(response.data[0])
