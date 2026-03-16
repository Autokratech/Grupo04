from app.schemas.user_schema import UserCreate
from app.services import users_service


def get_users():
    return users_service.list_users()


def get_user_by_id(user_id: int):
    return users_service.get_user(user_id)


def store_user(data: UserCreate):
    return users_service.create_user(data)
