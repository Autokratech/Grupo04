''' 
    Extensión de excepciones personalizadas para los diferentes servicios
'''

class DatabaseError(Exception):
    def __init__(self, cause):
        error_message = "Se ha producido un error en la conexión a la base de datos"
        if cause: error_message += f": {cause}"
        super().__init__(error_message)


class CacheError(Exception):
    def __init__(self, cause):
        error_message = "Se ha producido un error al intentar acceder al servicio de caché"
        if cause: error_message += f": {cause}"
        super().__init__(error_message)