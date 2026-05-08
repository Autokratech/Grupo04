from dotenv import load_dotenv
import os

load_dotenv()

#Mover esto a SECRET_MANAGER_URL para abstraerlo de la implementación de GCP o de Azure, luego procesar la url y si es <azure> > tirar contra el AKV / <google> tirar contra GCP

async def get_secret_manager_provider(secret_manager_provider): 

    secret_manager_provider = os.getenv("SECRET_MANAGER_PROVIDER")  #Determina si la api recupera sus secretos del manager de azure o google
    
    secret_manager_provider = "azure"
    if secret_manager_provider == "azure":
        from .secret_manager_providers.azure_secret_manager import azure
    elif secret_manager_provider == "gcp":
        from .secret_manager_providers.gcp_secret_manager import gcp
    else:
        raise ValueError("No se ha podido cargar la información del proveedor de secretos, o los datos proporcionados no corresponden a ningún provider registrado")

