from fastapi import APIRouter
from app.controllers.users_controller import get_users, get_user_by_id, store_user
from app.schemas.user_schema import UserCreate, UserResponse

router = APIRouter(
    prefix="/users",
    tags=["Users"]
)


@router.get("/", response_model=list[UserResponse])
def list_users():
    return get_users()


@router.get("/{user_id}", response_model=UserResponse)
def show_user(user_id: int):
    return get_user_by_id(user_id)


@router.post("/", response_model=UserResponse, status_code=201)
def create_user(data: UserCreate):
    return store_user(data)
