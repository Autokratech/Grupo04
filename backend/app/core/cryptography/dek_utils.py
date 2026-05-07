import secrets
import base64
from cryptography.fernet import Fernet, InvalidToken


#-- Método para generar una clave de encriptación en base64
def generate_dek(dek_size : int = 32):
    dek = secrets.token_bytes(dek_size)
    return base64.urlsafe_b64encode(dek)

#Nota: Existe un método con Fernet para generar la clave, pero es mejor que tengamos control sobre esa parte


#-- Método para encriptar un token con una dek en base64
def encrypt_token_with_dek(token : bytes, base64_dek):
    try: 
        #Para Fernet la DEK forzosamente debe tener una longitud de 32 bytes
        dek = base64.urlsafe_b64decode(base64_dek)
        if len(dek) != 32: raise ValueError(f"La DEK proporcionada debe tener una longitud de 32 bytes.")

        fernet_dek_key = Fernet(base64_dek)
        return fernet_dek_key.encrypt(token.encode())
    except TypeError:
        raise TypeError("No se ha podido realizar la encriptación porque la key proporcionada no posee un formato válido: bytes.")
    except Exception as e:
         raise Exception(f"Se ha producido un error inesperado durante el proceso de encriptación del token: {e}")


#-- Método para desencriptar un token previamente encriptado con una DEK
def decrypt_token_with_dek(token, base64_dek):
    try:
        dek = base64.urlsafe_b64decode(base64_dek)
        if len(dek) != 32: raise ValueError(f"La DEK proporcionada debe tener una longitud de 32 bytes.")

        fernet_dek_key = Fernet(base64_dek)
        return fernet_dek_key.decrypt(token)
    except TypeError:
        raise TypeError("No se ha podido realizar la desencriptación porque la key proporcionada no posee un formato válido: bytes.")
    except InvalidToken:
        raise InvalidToken("No se ha podido realizar la desencriptación porque el token proporcionado es inválido.")
    except Exception as e:
        raise Exception(f"Se ha producido un error inesperado durante el proceso de desencriptación del token: {e}")
