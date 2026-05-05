from requests_oauthlib import OAuth2Session
from .oauth_config import oauth_config
from fastapi import HTTPException

class OAuthManager:

    #Método para obtener la configuración específica del provider, definida en el fichero de configuración
    @staticmethod
    def get_oauth_config(provider):
        try:
            provider_config = oauth_config[provider]
            
            for key, value in provider_config.items():
                if not value:
                    raise ValueError(key)
            return provider_config
        
        except KeyError as e:
            raise HTTPException(status_code=404, detail=f"El provider {provider} no existe o no se ha podido obtener su configuración.")
        
        except ValueError as e:
            key = e.args[0]
            raise HTTPException(status_code=400, detail=f"La configuración del provider {provider} se encuentra incompleta: el valor de '{key}' está vacío.")


    #Método para crear una sesión OAuth a partir de la configuración específica del provider
    @staticmethod
    def get_oauth_session(provider):
        provider_config = OAuthManager.get_oauth_config(provider)

        try:
            oauth = OAuth2Session(
                client_id=provider_config["client_id"], 
                redirect_uri=provider_config["redirect_url"], 
                scope=provider_config["scopes"]
            )
            
            auth_url, state = oauth.authorization_url(provider_config["auth_url"])
            return oauth, auth_url, state
        
        except Exception as e:
            raise HTTPException(status_code=500, detail="Se ha producido un error inesperado al intentar crear la sesión OAuth con el provider {provider}.")


    #Método para intercambiar el código de autorización proporcionado por un token de acceso
    @staticmethod
    def get_oauth_token(provider, authorization_response, state):
        provider_config = OAuthManager.get_oauth_config(provider)

        oauth = OAuth2Session(
            client_id=provider_config["client_id"],
            redirect_uri=provider_config["redirect_url"],
            state=state
        )

        oauth_token = oauth.fetch_token(
            token_url=provider_config["token_url"],
            client_secret=provider_config["client_secret"],
            authorization_response=authorization_response
        )
        return oauth_token
    
    
#TODO: Investigar e implementar gestión del token de acceso del usuario + refresh token (¿Session BFF, cookie o BBDD?)
#TODO: Añadir gestión de errores try/catch específicas por tipo en get_oauth_session y get_oauth_token