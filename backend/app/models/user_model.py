from dataclasses import dataclass


@dataclass
class UserModel:
    id: int
    nombre: str
    email: str
    password_hash: str
