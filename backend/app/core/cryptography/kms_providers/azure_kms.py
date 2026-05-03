from azure.identity.aio import ClientSecretCredential
from azure.keyvault.keys.aio import KeyClient
from azure.keyvault.keys import KeyVaultKey
from azure.keyvault.keys.crypto.aio import CryptographyClient, KeyWrapAlgorithm
from app.core.cryptography.kms_providers.kms_client import IKMSClient
from app.core.exceptions import GenericError, KMSConnectionError
from azure.core.exceptions import AzureError, ClientAuthenticationError, ResourceNotFoundError
from dotenv import load_dotenv
import os

'''
Clase para trabajar con el KMS de Azure.
Permite obtener claves almacenadas en el Key Vault y realizar operaciones criptográficas.

El cliente ClientSecretCredential es necesario para autenticar la aplicación con el AAD de Azure (previamente registrada)
KeyClient permite gestionar las claves almacenadas en el KV
CryptographyClietn se utiliza para realizar operaciones criptográficas con dichas claves

'''

load_dotenv()

class AzureKMSClient(IKMSClient):
    

    def __init__(self):
        self.credential = self.get_kms_credential()
        self.key_client = self.get_key_client()


    # -- Credenciales necesarias para la conexión con los diferentes tipos de cliente (KeyClient, CryptographyClient)
    def get_kms_credential(self): 
        kms_tenant = os.getenv("KMS_TENANT_ID")
        kms_client_id = os.getenv("KMS_CLIENT_ID")
        kms_client_secret = os.getenv("KMS_CLIENT_SECRET")

        if any(not value for value in(kms_tenant, kms_client_id, kms_client_secret)):
            raise ValueError("No se han podido recuperar los datos necesarios para establecer la conexión con el key vault.")
        try:
            return ClientSecretCredential(kms_tenant, kms_client_id, kms_client_secret)
        except ClientAuthenticationError as e:
            raise KMSConnectionError(e)
        except Exception as e:
            raise GenericError(e)


    ## --- Creación del cliente para la gestión de claves criptográficas
    def get_key_client(self): 
        vault_url = os.getenv("KMS_INSTANCE_ENDPOINT")
        if not vault_url:
            raise ValueError("No se ha podido identificar la instancia de AKV necesaria para gestionar las claves.")
        try:     
            return KeyClient(vault_url, self.credential)
        except ClientAuthenticationError as e:
            raise KMSConnectionError(e)
        except AzureError as e:
            raise RuntimeError(f"Se ha producido un error al intentar generar el cliente KMS para la gestión de claves: {e}")
        except Exception as e:
            raise GenericError(e)


    # -- Método para obtener los datos de una clave de AKV (entre otras cosas, la versión actual de la key)
    async def get_key_data(self, key_name : str) -> KeyVaultKey:
        try:
            key_data = await self.key_client.get_key(key_name)
            return key_data
        except ResourceNotFoundError as e:
            raise ValueError(f"No se ha podido encontrar la key '{key_name}' especificada: {e}")
        except AzureError as e:
            raise RuntimeError(f"Error al obtener la KEK '{key_name}': {e}")
        except Exception as e:
            raise GenericError(e)


    # -- Método para rotar las claves del AKV
    #TODO: Revisar si como ya se programa la rotación directamente en el AKV, no la forzamos nunca y este método es innecesario
    async def rotate_key(self, key_name: str):
        pass


    ## -- Creación del cliente para la realización de operaciones criptográficas contra el key vault
    async def get_crypto_client(self, key_name : str): 
        try:
            #Para utilizar una clave con el CryptographyClient es recomendable obtener el objeto de la clave primero, ya que incluye la versión de la misma
            key_object = await self.get_key_data(key_name)
            return CryptographyClient(key_object, self.credential)
        except ClientAuthenticationError as e:
            raise KMSConnectionError(e)
        except Exception as e:
            raise GenericError(e)


    # -- Método para wrappear una key (DEK) con otra key (KEK)
    async def wrap_key(self, dek : bytes, kek_name : str) -> bytes:
        try:
            crypto_client = await self.get_crypto_client(kek_name)
            key_wrapped = await crypto_client.wrap_key(KeyWrapAlgorithm.rsa_oaep, dek)
            return key_wrapped.encrypted_key
        except Exception as e:
            raise GenericError(e)
        finally:
            if crypto_client:
                await crypto_client.close()

    # -- Método para unwrappear la DEK wrappeada con su correspondiente KEK
    async def unwrap_key(self, wrapped_dek : bytes, kek_name : str) -> bytes: 
        try:
            crypto_client = await self.get_crypto_client(kek_name)
            key_unwrapped = await crypto_client.unwrap_key(KeyWrapAlgorithm.rsa_oaep, wrapped_dek)
            return key_unwrapped.key
        except Exception as e:
            raise GenericError(e)
        finally:
            if crypto_client:
                await crypto_client.close()
