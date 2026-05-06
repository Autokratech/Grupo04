from dataclasses import dataclass


@dataclass
class ModeloUsuario:
    id: int | None
    nombre: str
    email: str
    password_hash: str
