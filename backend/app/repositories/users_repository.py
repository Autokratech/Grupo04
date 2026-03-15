from app.core.database import FAKE_USERS, next_user_id
from app.models.user_model import UserModel


def get_all_users():
    return FAKE_USERS


def get_user_by_id(user_id: int):
    for user in FAKE_USERS:
        if user.id == user_id:
            return user
    return None


def get_user_by_email(email: str):
    for user in FAKE_USERS:
        if user.email == email:
            return user
    return None


def create_user(nombre: str, email: str, password_hash: str):
    user = UserModel(
        id=next_user_id(),
        nombre=nombre,
        email=email,
        password_hash=password_hash
    )
    FAKE_USERS.append(user)
    return user
