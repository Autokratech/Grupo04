''' 
    Extensión de excepciones personalizadas para los diferentes servicios
'''

# -- Clase para capturar errores genéricos, no contemplados por el resto
class GenericError(Exception):
    def __init__(self, cause):
        error_message = "Se ha producido un error inesperado"
        if cause: error_message += f": {cause}"
        super().__init__(error_message)


class DatabaseError(Exception):
    def __init__(self, cause):
        error_message = "Se ha producido un error en la solicitud a la base de datos"
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


#-- Clase para gestionar las excepciones HTTP de Azure, basada en su excepción general HTTPResponseError
class AzureHTTPError(Exception):
    def __init__(self, cause):
        if cause.response.status_code == 401:
            error_message = "Error de autenticación "
        elif cause.response.status_code == 403:
            error_message = "Error de autorización "
        elif cause.response.status_code == 404:
            error_message = "Recurso no encontrado "
        elif cause.response.status_code == 500:
            error_message = "Error del servidor"
        else:
            error_message = ""
        if cause: error_message += f": {cause.message}"
        super().__init__(error_message)


#-- Clases para gestionar solicitudes incorrectas recibidas por la aplicación (ausencia de parámetros obligatorios, etc)
class BadRequestError(Exception):
    def __init__(self, cause):
        error_message = "El formato de la petición no es correcto"
        if cause: error_message += f": {cause}"
        super().__init__(error_message)

class InvalidValueError(Exception):
    def __init__(self, cause):
        error_message = "El valor proporcionado es inválido"
        if cause: error_message += f": {cause}"
        super().__init__(error_message)
