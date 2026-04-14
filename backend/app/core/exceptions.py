''' 
    Extensión de excepciones personalizadas para los diferentes servicios
'''

# -- Clase para capturar errores genéricos, no contemplados por el resto
class GenericError(Exception):
    def __init__(self, cause):
        error_message = "Se ha producido un error inesperado"
        if cause: error_message += f": {cause}"
        super().__init__(error_message)


# -- TODO: Revisar procesamiento de los errores de las clases subsiguientes, para una mayor granularidad
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


class KMSConnectionError(Exception):
    def __init__(self, cause):
        error_message = "Se ha producido un error al intentar conectar con el cliente KMS"
        if cause: error_message += f": {cause}"
        super().__init__(error_message)


# Clase para gestionar las excepciones HTTP de Azure, basada en su excepción general HTTPResponseError
class AzureHTTPError(Exception):
    def __init__(self, cause):
        if cause.response.status_code == 401:
            error_message = "Error de autenticación "
        elif cause.response.status_code == 403:
            error_message = "Error de autorización "
        elif cause.response.status_code == 404:
            error_message = "Error de autenticación "
        elif cause.response.status_code == 500:
            error_message = "Error del servidor"
        else:
            error_message = ""
        if cause: error_message += f": {cause.message}"
        super().__init__(error_message)

