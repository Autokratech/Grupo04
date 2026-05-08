from azure.identity import ClientSecretCredential
from azure.keyvault.secrets import SecretClient
from azure.core.exceptions import AzureError
from dotenv import load_dotenv
import os

load_dotenv()

# -- Credenciales para la conexión
async def get_secret_manager_credential(): 
    secret_manager_tenant = os.getenv("SECRET_MANAGER_TENANT_ID")
    secret_manager_client_id = os.getenv("SECRET_MANAGER_CLIENT_ID")
    secret_manager_client_secret = os.getenv("SECRET_MANAGER_CLIENT_SECRET")

    if any(not value for value in(secret_manager_tenant, secret_manager_client_id, secret_manager_client_secret)):
        raise ValueError("No se han podido recuperar los datos necesarios para establecer la conexión con el key vault.")
    try:
        return ClientSecretCredential(secret_manager_tenant, secret_manager_client_id, secret_manager_client_secret)
    except AzureError as e:
        print(f"Se ha producido un error al intentar generar el cliente de Azure: {e}")
    except Exception as e:
        print(f"Se ha producido un error inesperado: {e}")


# -- Creación del cliente para la gestión de secretos
async def get_secret_client(credential):
    try:
        return SecretClient(vault_url="https://autokratech-kv.vault.azure.net/", credential=credential)
    except AzureError as e:
        print(f"Se ha producido un error al intentar generar el cliente para la gestión de secretos: {e}")
    except Exception as e:
        print(f"Se ha producido un error inesperado: {e}")


# -- Método para almacenar un secreto en AKV
async def set_secret(secret_key, secret_value, secret_client):
    try:
        secret_client.set_secret(secret_key, secret_value)
    except AzureError as e:
        print(f"Se ha producido un error al guardar el secreto {secret_key}: {e}")
    except Exception as e:
        print(f"Se ha producido un error inesperado: {e}")


# -- Método para obtener el valor de un secreto almacenado en AKV
async def get_secret(secret_key, secret_client):
    try:
        secret_value = secret_client.get_secret(secret_key)
        return secret_value
    except AzureError as e:
        print(f"Se ha producido un error al recuperar el secreto {secret_key}: {e}")
    except Exception as e:
        print(f"Se ha producido un error inesperado: {e}")

