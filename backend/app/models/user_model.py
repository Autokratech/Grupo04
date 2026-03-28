from dataclasses import dataclass


@dataclass
class ModeloUsuario:
    id: int
    nombre: str
    email: str
    password_hash: str
